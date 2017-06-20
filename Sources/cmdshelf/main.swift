import Commander
import PathKit
import Foundation
import ShellOut

let version = "0.2.1"

let group = Group { group in
    group.addCommand("remote", RemoteCommand())
    group.addCommand("list", command() {
        let config = try Configuration()
        try config.printAllCommands()
    })
    group.addCommand("run", command(
        Argument<String>("COMMAND", description: "command name alias")
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

            safeShellOutAndPrint(to: "bash <(curl -s \"\(url)\")")
            return
        } else if let localPath = config.cmdshelfYml.blobLocalPath(for: name) {
            safeShellOutAndPrint(to: localPath, arguments: parameters)
            return
        }

        // Search in remote
        try config.cloneRemotesIfNeeded()
        // Note: performs no updates
        if let localPath = config.remote(for: name) {
            safeShellOutAndPrint(to: localPath.string, arguments: parameters)
            return
        }

        // Search in swiftpm
        if let repository = config.cmdshelfYml.swiftpms.find({ $0.name == name }) {
            try config.cloneSwiftpmIfNeeded(repository: repository)
            // Note: performs no updates
            try config.buildSwiftpm(repository: repository)
            if let localPath = config.swiftpm(for: name) {
                safeShellOutAndPrint(to: localPath.string, arguments: parameters)
                return
            }
        }
        queuedPrintln("Command \(command) not found.")
        exit(1)
    })
    group.addCommand("blob", BlobCommand())
    group.addCommand("update", command() {
        let config = try Configuration()
        try config.cloneRemotesIfNeeded()
        try config.updateRemotes()
        try config.cloneSwiftpmsIfNeeded()
        try config.updateSwiftpms()
    })
    group.addCommand("swiftpm", SwiftPMCommand())
    group.addCommand("bootstrap", command() {
        let config = try Configuration()
        try config.cloneRemotesIfNeeded()
        try config.updateRemotes()
        try config.cloneSwiftpmsIfNeeded()
        try config.updateSwiftpms()
        try config.buildSwiftpms()
    })
}

group.run(version)
