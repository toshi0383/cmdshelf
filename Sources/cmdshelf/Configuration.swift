import Foundation
import PathKit
import Yams
import ShellOut

enum Const {
    static let ymlPath = Path("~/.cmdshelf.yml").absolute()
    private static let workspacePath = Path("~/.cmdshelf").absolute()
    static let remoteWorkspacePath = Const.workspacePath + "remote"
    static let swiftpmWorkspacePath = Const.workspacePath + "swiftpm"
}

func commandToDictionary(_ commands: [Command]) -> [String: [String: String]] {
    var r = [String: [String: String]]()
    for c in commands {
        r[c.name] = ["url": c.url]
    }
    return r
}
struct CmdshelfYaml: NodeRepresentable {
    var commands: [Command] = []
    var remotes: [Command] {
        return commands.filter { $0.type == .remote }
    }
    var blobs: [Command] {
        return commands.filter { $0.type == .blob }
    }
    var swiftpms: [Command] {
        return commands.filter { $0.type == .swiftpm }
    }
    mutating func addRemote(name: String, url: String) {
        commands.append(Command(name: name, url: url, type: .remote))
    }
    mutating func removeRemote(name: String) {
        guard remotes.map({ $0.name }).contains(name) else {
            return
        }
        commands.remove(name: name)
        // TODO: clean cloned repo
    }
    mutating func addBlob(name: String, url: String) {
        commands.append(Command(name: name, url: url, type: .blob))
    }
    mutating func removeBlob(name: String) {
        guard blobs.map({ $0.name }).contains(name) else {
            return
        }
        commands.remove(name: name)
    }
    mutating func addSwiftPM(name: String, url: String) {
        commands.append(Command(name: name, url: url, type: .swiftpm))
    }
    mutating func removeSwiftpm(name: String) {
        guard swiftpms.map({ $0.name }).contains(name) else {
            return
        }
        commands.remove(name: name)
        // TODO: clean cloned repo
    }
    func represented() throws -> Node {
        return [
            "remote": try Node(commandToDictionary(remotes)),
            "blob": try Node(commandToDictionary(blobs)),
            "swiftpm": try Node(commandToDictionary(swiftpms)),
        ]
    }
    func blobURL(for name: String) -> String? {
        return blobs.filter { $0.name == name }.flatMap { $0.url }.first
    }
    func remoteURL(for name: String) -> String? {
        return remotes.filter { $0.name == name }.flatMap { $0.url }.first
    }
    func swiftpmURL(for name: String) -> String? {
        return swiftpms.filter { $0.name == name }.flatMap { $0.url }.first
    }
}

class Configuration {
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
                        self.cmdshelfYml.commands.append(Command(name: name, url: url, type: .remote))
                    }
                }
            }
            if let blob = yml["blob"] as? [String: [String: String]] {
                for (name, dictionary) in blob {
                    if let url = dictionary["url"] {
                        self.cmdshelfYml.commands.append(Command(name: name, url: url, type: .blob))
                    }
                }
            }
            if let swiftpm = yml["swiftpm"] as? [String: [String: String]] {
                for (name, dictionary) in swiftpm {
                    if let url = dictionary["url"] {
                        self.cmdshelfYml.commands.append(Command(name: name, url: url, type: .swiftpm))
                    }
                }
            }
        }
    }
    func cloneRemotesIfNeeded() throws {
        try cloneURLIfNeeded(workspacePath: Const.remoteWorkspacePath, commands: cmdshelfYml.remotes)
    }
    func cloneSwiftpmsIfNeeded() throws {
        try cloneURLIfNeeded(workspacePath: Const.swiftpmWorkspacePath, commands: cmdshelfYml.swiftpms, atLatestTag: true)
    }
    func cloneSwiftpmIfNeeded(command: Command) throws {
        let workspace = Const.swiftpmWorkspacePath + command.name
        if workspace.isDirectory == false {
            try shellOutAndPrint(to: "git clone \(command.url) \(workspace.string)")
        }
    }
    func buildSwiftpms() throws {
        for s in cmdshelfYml.swiftpms {
            try buildSwiftpm(command: s)
        }
    }
    func buildSwiftpm(command: Command) throws {
        let workspace = Const.swiftpmWorkspacePath + command.name
        guard workspace.isDirectory else {
            throw CmdshelfError("Swiftpm command: \(command) not found.")
        }
        try shellOutAndPrint(to: "cd \(workspace.string); swift build -c release")
    }
    func updateSwiftpms() throws {
        for command in cmdshelfYml.swiftpms {
            let workspace = Const.swiftpmWorkspacePath + command.name
            guard workspace.isDirectory else {
                throw CmdshelfError("Swiftpm command: \(command) not found.")
            }
            // Checkout the latest tag
            try shellOutAndPrint(to: "cd \(workspace.string); git fetch --tag; git checkout $(git describe --tags)")
        }
    }
    private func cloneURLIfNeeded(workspacePath: Path, commands: [Command], atLatestTag: Bool = false) throws {
        for command in commands {
            let workspace = workspacePath + command.name
            if workspace.isDirectory == false {
                try shellOutAndPrint(to: "git clone \(command.url) \(workspace.string)")
                if atLatestTag {
                    try shellOutAndPrint(to: "cd \(workspace.string); git checkout $(git describe --tags)")
                }
            }
        }
    }
    func updateRemotes() throws {
        for command in cmdshelfYml.remotes {
            let workspace = Const.remoteWorkspacePath + command.name
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
    func printAllCommands() throws {
        try cloneRemotesIfNeeded()
        let allRemoteCommands = try cmdshelfYml.remotes
            .map { (Const.remoteWorkspacePath + $0.name, $0.name) }
            .flatMap {
                let repoPath = $0
                let commands = try $0.recursiveChildren()
                    .filter {
                        $0.isExecutable
                            && $0.isDirectory == false
                            && $0.components.contains(".git") == false
                    }
                    .map { $0.string.substring(from: (repoPath.string + "/").endIndex) }
                    .joined(separator: "\n    ")
                return "  \($1):\n    \(commands)"
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
