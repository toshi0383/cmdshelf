import Commander
import PathKit
import Foundation
import Reporter

class SwiftPMCommand: Group {
    override init() {
        super.init()
        func _warning() {
            queuedPrintlnWarning("[WARNING] swiftpm sub-command is deprecated and will be removed in future.\n See https://github.com/toshi0383/cmdshelf/issues/11 for detail.")
        }
        addCommand("list", "Show registered swiftpms.", Commander.command() {
            _warning()
            let config = try Configuration()
            queuedPrintln(config.cmdshelfYml.swiftpms.map { "\($0.name): \($0.url)" }.joined(separator: "\n"))
        })
        addCommand("add", "Add a repository URL as a swiftpm.", Commander.command(
            Argument<String>("NAME", description: "command name alias"),
            Argument<String>("URL", description: "repository URL", validator: validURL)
        ) { (name, url) in
            _warning()
            let config = try Configuration()
            config.cmdshelfYml.swiftpms.append(Repository(name: name, url: url, tag: nil, branch: nil))
        })
        addCommand("remove", "Remove a swiftpm.", Commander.command(
            Argument<String>("NAME", description: "command name")
        ) { name in
            _warning()
            let config = try Configuration()
            config.cmdshelfYml.removeSwiftpm(name: name)
        })
    }
}
