import Commander
import PathKit
import Foundation
import Reporter

class RemoteCommand: Group {
    let name: String = "remote"
    let description: String? = "Manage remote commands (type `cmdshelf remote` for usage)"
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
            Argument<String>("NAME", description: "remote name")
        ) { name in
            let config = try Configuration()
            config.cmdshelfYml.removeRemote(name: name)
        })
    }
}
