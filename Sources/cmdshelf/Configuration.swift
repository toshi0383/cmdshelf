import Foundation
import PathKit
import Reporter
import Yams

enum Const {
    fileprivate static let ymlPath = Path("~/.cmdshelf.yml").absolute()
    private static let workspacePath = Path("~/.cmdshelf").absolute()
    fileprivate static let remoteWorkspacePath = Const.workspacePath + "remote"
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
            queuedPrintlnError(error)
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
                    } else if let localPath = dictionary["localPath"] {
                        cmdshelfYml.blobs.append(Blob(name: name, localPath: localPath))
                    }
                }
            }
        }
    }
    func cloneRemotesIfNeeded() {
        cloneURLIfNeeded(workspacePath: Const.remoteWorkspacePath, repositories: cmdshelfYml.remotes)
    }
    private func cloneURLIfNeeded(workspacePath: Path, repositories: [Repository]) {
        for repo in repositories {
            let workspace = workspacePath + repo.name
            if workspace.isDirectory == false {
                queuedPrint("[\(repo.name)] Cloning ...")
                let status = silentShellOut(to: "git clone \(repo.url) \(workspace.string)")
                if status != 0 {
                    queuedPrintlnError("error")
                } else {
                    queuedPrintln("success", color: .green)
                }
            }
        }
    }
    func updateRemotes() {
        for repo in cmdshelfYml.remotes {
            let workspace = Const.remoteWorkspacePath + repo.name
            if workspace.isDirectory {
                queuedPrint("[\(repo.name)] Updating ... ")
                let status = silentShellOut(to: "cd \(workspace.string) && git fetch origin master && git checkout origin/master")
                if status != 0 {
                    queuedPrintlnError("error")
                } else {
                    queuedPrintln("success", color: .green)
                }
            }
        }
    }
    func remote(for name: String) -> Path? {
        return cmdshelfYml.remotes
            .map { Const.remoteWorkspacePath + $0.name + name }
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
        cloneRemotesIfNeeded()
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
            queuedPrintln("  " + cmdshelfYml.blobs.map { "\($0.name): \($0.url ?? $0.localPath!)" }.joined(separator: "\n  "))
            queuedPrintln("")
        }
        if cmdshelfYml.remotes.isEmpty == false {
            queuedPrintln("remote:")
            queuedPrintln("\(allRemoteCommands)")
            queuedPrintln("")
        }
    }
}
