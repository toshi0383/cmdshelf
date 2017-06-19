import Commander
import PathKit
import Foundation
import ShellOut

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

            try shellOutAndPrint(to: "bash <(curl -s \"\(url)\")")
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
        if let command = config.cmdshelfYml.swiftpms.filter({ $0.name == name }).first {
            try config.cloneSwiftpmIfNeeded(command: command)
            // Note: performs no updates
            try config.buildSwiftpm(command: command)
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
        try config.updateRemotes()
        try config.updateSwiftpms()
        try config.buildSwiftpms()
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

group.run("0.1.0")
