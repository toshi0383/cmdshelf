import Foundation
import Reporter
import Yams

enum Const {
    fileprivate static let ymlPath = "~/.cmdshelf.yml".standardizingPath
    private static let workspacePath = "~/.cmdshelf".standardizingPath
    fileprivate static let remoteWorkspacePath = "\(Const.workspacePath)/remote"
}

enum DisplayType: String {
    case alias, absolutePath
}

internal let fm = FileManager.default

class Configuration {

    var remoteWorkspacePath: String {
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
            try string.write(toFile: Const.ymlPath, atomically: true, encoding: .utf8)
        } catch {
            queuedPrintlnError(error)
        }
    }

    init() throws {
        if fm.fileExists(atPath: Const.ymlPath) {
            guard fm.isReadableFile(atPath: Const.ymlPath) else {
                throw CmdshelfError("""
                    \(Const.ymlPath) is expected to be a file but is not. Please remove or rename existing file or directory.
                    """)
            }

            let url = URL(fileURLWithPath: Const.ymlPath)
            let data = try String(contentsOfFile: url.path, encoding: .utf8)

            guard let yml = try Yams.load(yaml: data) as? [String: Any] else {
                throw CmdshelfError("Failed to load \(Const.ymlPath).")
            }

            if let remote = yml["remote"] as? [String: [String: String]] {
                for (name, dictionary) in remote {
                    if let url = dictionary["url"] {
                        let repository = Repository(name: name,
                                                    url: url,
                                                    tag: dictionary["tag"],
                                                    branch: dictionary["branch"])
                        cmdshelfYml.remotes.append(repository)
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

    private func cloneURLIfNeeded(workspacePath: String, repositories: [Repository]) {
        for repo in repositories {

            let workspace = "\(workspacePath)/\(repo.name)"

            if !fm.isDirectory(workspace) {

                queuedPrint("[\(repo.name)] Cloning ... ")

                let status = silentShellOut(to: "git clone \(repo.url) \(workspace)")

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
            let workspace = "\(Const.remoteWorkspacePath)/\(repo.name)"

            if fm.isDirectory(workspace) {

                queuedPrint("[\(repo.name)] Updating ... ")

                let status = silentShellOut(to: "cd \(workspace) && git fetch origin master && git checkout origin/master")

                if status != 0 {
                    queuedPrintlnError("error")
                } else {
                    queuedPrintln("success", color: .green)
                }
            }
        }
    }
    private func getContextForRemote(alias: String, remoteName: String? = nil) -> Context? {
        return cmdshelfYml.remotes
            .filter {
                if let remoteName = remoteName {
                    return $0.name == remoteName
                } else {
                    return true
                }
            }
            .map { "\(Const.remoteWorkspacePath)/\($0.name)/\(alias)" }
            .filter(fm.isExecutableFile(atPath:))
            .first
            .map { Context(location: $0) }
    }

    func displayNames(for remoteName: String, type: DisplayType) throws -> [String] {
        let repoPath = "\(Const.remoteWorkspacePath)/\(remoteName)"
        func _convert(path: String) -> String {
            if type == .alias {
                if let upperBound = path.range(of: repoPath + "/")?.upperBound {
                    return String(path[upperBound..<path.endIndex])
                } else {
                    fatalError("Could not construct correct path name to display.")
                }
            }
            return path
        }

        return try fm.subpathsOfDirectory(atPath: repoPath)
            .map { "\(repoPath)/\($0)" }
            .filter {
                fm.isExecutableFile(atPath: $0)
                    && !fm.isDirectory($0)
                    && !$0.components(separatedBy: "/").contains(".git")
            }
            .map(_convert)
    }

    func getContexts(for alias: String, remoteName: String? = nil) -> [Context] {
        var contexts = [Context]()
        if remoteName == nil {
            // Search in blob
            if let url = cmdshelfYml.blobURL(for: alias) {
                // TODO:
                //   if let localURL = config.cache(for: url) {
                contexts.append(Context(location: "curl -sSL \"\(url)\""))
            } else if let localPath = cmdshelfYml.blobLocalPath(for: alias) {
                contexts.append(Context(location: localPath))
            }
        }
        // Search in remote
        cloneRemotesIfNeeded()
        if let c = getContextForRemote(alias: alias, remoteName: remoteName) {
            contexts.append(c)
        }
        return contexts
    }

    func printAllCommands(displayType: DisplayType) throws {
        cloneRemotesIfNeeded()
        let allRemoteCommands = try cmdshelfYml.remotes
            .map { $0.name }
            .flatMap {
                let names = try self.displayNames(for: $0, type: displayType)
                    .joined(separator: "\n    ")
                return "  \($0):\n    \(names)"
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
