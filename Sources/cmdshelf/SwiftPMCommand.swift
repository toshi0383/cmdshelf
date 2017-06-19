import Commander
import PathKit
import Foundation

class SwiftPMCommand: Group {
    override init() {
        super.init()
        addCommand("list", "Show registered swiftpms.", Commander.command() {
            let config = try Configuration()
            queuedPrintln(config.cmdshelfYml.swiftpms.map { "\($0.name): \($0.url)" }.joined(separator: "\n"))
        })
        addCommand("add", "Add a repository URL as a swiftpm.", Commander.command(
            Argument<String>("NAME", description: "command name alias"),
            Argument<String>("URL", description: "repository URL", validator: validURL)
        ) { (name, url) in
            let config = try Configuration()
            config.cmdshelfYml.addSwiftPM(name: name, url: url)
        })
        addCommand("remove", "Remove a swiftpm.", Commander.command(
            Argument<String>("NAME", description: "command name")
        ) { name in
            let config = try Configuration()
            config.cmdshelfYml.removeSwiftpm(name: name)
        })
    }
}
