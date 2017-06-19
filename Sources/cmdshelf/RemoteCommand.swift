import Commander
import PathKit
import Foundation

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
            config.cmdshelfYml.addRemote(name: name, url: url)
        })
        addCommand("remove", "Remove a remote.", Commander.command(
            Argument<String>("NAME", description: "command name")
        ) { name in
            let config = try Configuration()
            config.cmdshelfYml.removeRemote(name: name)
        })
    }
}
