import Foundation
import PathKit
import Yams
import ShellOut

enum Const {
    fileprivate static let ymlPath = Path("~/.cmdshelf.yml").absolute()
    private static let workspacePath = Path("~/.cmdshelf").absolute()
    fileprivate static let remoteWorkspacePath = Const.workspacePath + "remote"
    fileprivate static let swiftpmWorkspacePath = Const.workspacePath + "swiftpm"
}

class Configuration {
    var remoteWorkspacePath: Path {
        return Const.remoteWorkspacePath
    }
    var cmdshelfYml: CmdshelfYaml = .init() {
        didSet {
            writeYml()
        }
    }
    private func writeYml() {
        do {
            let node = try cmdshelfYml.represented()
            let string = try Yams.serialize(node: node)
            try Const.ymlPath.write(string)
        } catch {
            queuedPrintln(error)
        }
    }
    init() throws {
        if Const.ymlPath.exists {
            guard Const.ymlPath.isFile else {
                throw CmdshelfError("\(Const.ymlPath.string) is expected to be a file but is not. Please remove or rename existing file or directory.")
            }
            let url = URL(fileURLWithPath: Const.ymlPath.string)
            let data = try String(contentsOf: url)
            guard let yml = try Yams.load(yaml: data) as? [String: Any] else {
                throw CmdshelfError("Failed to load \(Const.ymlPath.string).")
            }
            if let remote = yml["remote"] as? [String: [String: String]] {
                for (name, dictionary) in remote {
                    if let url = dictionary["url"] {
                        cmdshelfYml.remotes.append(Repository(name: name, url: url, tag: dictionary["tag"], branch: dictionary["branch"]))
                    }
                }
            }
            if let blob = yml["blob"] as? [String: [String: String]] {
                for (name, dictionary) in blob {
                    if let url = dictionary["url"] {
                        cmdshelfYml.blobs.append(Blob(name: name, url: url))
                    }
                }
            }
            if let swiftpm = yml["swiftpm"] as? [String: [String: String]] {
                for (name, dictionary) in swiftpm {
                    if let url = dictionary["url"] {
                        cmdshelfYml.swiftpms.append(Repository(name: name, url: url, tag: dictionary["tag"], branch: dictionary["branch"]))
                    }
                }
            }
        }
    }
    func cloneRemotesIfNeeded() throws {
        try cloneURLIfNeeded(workspacePath: Const.remoteWorkspacePath, repositories: cmdshelfYml.remotes)
    }
    func cloneSwiftpmsIfNeeded() throws {
        try cloneURLIfNeeded(workspacePath: Const.swiftpmWorkspacePath, repositories: cmdshelfYml.swiftpms)
    }
    func cloneSwiftpmIfNeeded(repository: Repository) throws {
        let workspace = Const.swiftpmWorkspacePath + repository.name
        if workspace.isDirectory == false {
            safeShellOutAndPrint(to: "git clone \(repository.url) \(workspace.string)")
        }
    }
    func buildSwiftpms() throws {
        for s in cmdshelfYml.swiftpms {
            try buildSwiftpm(repository: s)
        }
    }
    func buildSwiftpm(repository: Repository) throws {
        queuedPrintln("[\(repository.name)] Building...")
        let workspace = Const.swiftpmWorkspacePath + repository.name
        guard workspace.isDirectory else {
            throw CmdshelfError("Swiftpm command: \(repository.name) not found.")
        }
        do {
            try shellOutAndPrint(to: "cd \(workspace.string); swift build -c release")
        } catch let error as ShellOutError {
            throw CmdshelfError("[ERROR] \(error.message)")
        }
    }
    func updateSwiftpms() throws {
        for repo in cmdshelfYml.swiftpms {
            queuedPrintln("[\(repo.name)] Updating...")
            do {
                let workspace = Const.swiftpmWorkspacePath + repo.name
                guard workspace.isDirectory else {
                    throw CmdshelfError("Swiftpm command: \(repo.name) not found.")
                }
                let cdAndFetchTags = "cd \(workspace.string); git fetch --all --tag"
                let gitDescribeTag = "cd \(workspace.string); git describe --tags --abbrev=0"
                if let tag = repo.tag {
                    queuedPrintln("[\(repo.name)] Checking out tag: \(tag) ...")
                    try shellOutAndPrint(to: "\(cdAndFetchTags); git checkout \(tag)")
                } else if let branch = repo.branch {
                    queuedPrintln("[\(repo.name)] Checking out branch: \(branch) ...")
                    try shellOutAndPrint(to: "\(cdAndFetchTags); git checkout origin/\(branch)")
                } else {
                    // Checkout the latest tag
                    let tag = try shellOut(to: gitDescribeTag)
                    queuedPrintln("[\(repo.name)] Checking out the latest tag \(tag) ...")
                    try shellOutAndPrint(to: "\(cdAndFetchTags); git checkout \(tag)")
                    cmdshelfYml.swiftpms.remove { $0 == repo }
                    cmdshelfYml.swiftpms.append(
                        Repository(name: repo.name, url: repo.url, tag: tag, branch: nil)
                    )
                }
            } catch let error as ShellOutError {
                queuedPrintln(error.message) // Prints STDERR
            }
        }
    }
    private func cloneURLIfNeeded(workspacePath: Path, repositories: [Repository]) throws {
        for repo in repositories {
            let workspace = workspacePath + repo.name
            if workspace.isDirectory == false {
                queuedPrintln("[\(repo.name)] Cloning...")
                safeShellOutAndPrint(to: "git clone \(repo.url) \(workspace.string)")
            }
        }
    }
    func updateRemotes() throws {
        for repo in cmdshelfYml.remotes {
            let workspace = Const.remoteWorkspacePath + repo.name
            if workspace.isDirectory {
                safeShellOutAndPrint(to: "cd \(workspace.string); git pull")
            }
        }
    }
    func remote(for name: String) -> Path? {
        return cmdshelfYml.remotes
            .map { Const.remoteWorkspacePath + $0.name + name }
            .filter { $0.isExecutable }
            .first
    }
    func swiftpm(for moduleName: String) -> Path? {
        return cmdshelfYml.swiftpms
            .filter { $0.name == moduleName }
            .map { Const.swiftpmWorkspacePath + $0.name + ".build/release/\(moduleName)"}
            .filter { $0.isExecutable }
            .first
    }

    func commandNames(for remoteName: String) throws -> [String] {
        let repoPath = Const.remoteWorkspacePath + remoteName
        return try repoPath.recursiveChildren()
            .filter {
                $0.isExecutable
                    && $0.isDirectory == false
                    && $0.components.contains(".git") == false
            }
            .map { $0.string.substring(from: (repoPath.string + "/").endIndex) }
    }

    func printAllCommands() throws {
        try cloneRemotesIfNeeded()
        let allRemoteCommands = try cmdshelfYml.remotes
            .map { $0.name }
            .flatMap {
                let commands = try self.commandNames(for: $0)
                    .joined(separator: "\n    ")
                return "  \($0):\n    \(commands)"
            }
            .joined(separator: "\n\n")
        if cmdshelfYml.blobs.isEmpty == false {
            queuedPrintln("blob:")
            queuedPrintln("  " + cmdshelfYml.blobs.map { "\($0.name): \($0.url)" }.joined(separator: "\n  "))
            queuedPrintln("")
        }
        if cmdshelfYml.remotes.isEmpty == false {
            queuedPrintln("remote:")
            queuedPrintln("\(allRemoteCommands)")
            queuedPrintln("")
        }
        if cmdshelfYml.swiftpms.isEmpty == false {
            queuedPrintln("swiftpm:")
            queuedPrintln("  " + cmdshelfYml.swiftpms.map { "\($0.name): \($0.url)" }.joined(separator: "\n  "))
        }
    }
}
