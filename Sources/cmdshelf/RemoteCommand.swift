import Commander
import PathKit
import Foundation
import Reporter

class RemoteCommand: Group {
    override init() {
        super.init()
        addCommand("list", "Show registered remotes.", Commander.command() {
            let config = try Configuration()
            queuedPrintln(config.cmdshelfYml.remotes.map { "\($0.name): \($0.url)" }.joined(separator: "\n"))
        })
        addCommand("add", "Add a git repository as a remote.", Commander.command(
            Argument<String>("NAME", description: "command name alias"),
            Argument<String>("URL", description: "script URL", validator: validURL)
        ) { (name, url) in
            let config = try Configuration()
            config.cmdshelfYml.remotes.append(Repository(name: name, url: url, tag: nil, branch: nil))
        })
        addCommand("remove", "Remove a remote.", Commander.command(
            Argument<String>("NAME", description: "command name")
        ) { name in
            let config = try Configuration()
            config.cmdshelfYml.removeRemote(name: name)
        })
        addCommand("run", "Run command from specified remote.", Commander.command(
            Argument<String>("NAME", description: "remote name"),
            Argument<String>("COMMAND", description: "command name alias")
        ) { (remoteName, command) in
            guard let name = command.components(separatedBy: " ").first else {
                return
            }
            let parameters = command.components(separatedBy: " ").dropFirst().map { $0 }
            let config = try Configuration()
            try config.cloneRemotesIfNeeded()
            // Note: performs no updates
            guard let remote = config.cmdshelfYml.remotes.filter({ $0.name == remoteName }).first else {
                throw CmdshelfError("Invalid remote name: \(remoteName))")
            }
            guard let commandName = try config.commandNames(for: remote.name).filter({ $0 == name }).first else {
                throw CmdshelfError("Invalid command name for remote \(remote.name): \(name)")
            }
            let localPath = config.remoteWorkspacePath + remoteName + commandName
            safeShellOutAndPrint(to: localPath.string, arguments: parameters)
        })
    }
}
