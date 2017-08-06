import Commander
import PathKit
import Foundation
import Reporter

let version = "0.3.1"

let group = Group { group in
    group.addCommand("list", command() {
        let config = try Configuration()
        try config.printAllCommands()
    })
    group.addCommand("remote", RemoteCommand())
    group.addCommand("blob", BlobCommand())
    group.addCommand("run", command(
        Argument<String>("COMMAND", description: "command name alias double or single quoted when passing arguments. e.g. `cmdshelf run \"myscript --option someargument\"")
    ) { (command) in
        guard let name = command.components(separatedBy: " ").first else {
            return
        }
        let parameters = command.components(separatedBy: " ").dropFirst().map { $0 }
        let config = try Configuration()

        // Search in blob
        if let url = config.cmdshelfYml.blobURL(for: name) {
            // TODO:
            //   if let localURL = config.cache(for: url) {
            shellOut(to: "bash <(curl -s \"\(url)\")", arguments: parameters)
            return
        } else if let localPath = config.cmdshelfYml.blobLocalPath(for: name) {
            shellOut(to: localPath, arguments: parameters)
            return
        }

        // Search in remote
        config.cloneRemotesIfNeeded()
        // Note: performs no updates
        if let localPath = config.remote(for: name) {
            shellOut(to: localPath.string, arguments: parameters)
            return
        }

        queuedPrintlnError("Command `\(command)` not found.")
        exit(1)
    })
    group.addCommand("update", command() {
        let config = try Configuration()
        config.cloneRemotesIfNeeded()
        config.updateRemotes()
    })
}

group.run(version)
