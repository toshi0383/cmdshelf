import Commander
import PathKit
import Foundation
import Reporter

let version = "0.7.2"

let blob = BlobCommand()

let cat = command(VaradicAliasArgument()) { (aliases) in
    if aliases.isEmpty {
        shellOut(to: "cat")
    } else {
        let config = try Configuration()
        config.cloneRemotesIfNeeded()
        var failure = false
        for alias in aliases {
            // Search in blobs and remote
            guard let context = config.getContexts(for: alias.alias, remoteName: alias.remoteName).first else {
                queuedPrintlnError(Message.noSuchCommand(alias.originalValue))
                failure = true
                continue
            }
            if context.location.hasPrefix("curl ") {
                shellOut(to: context.location)
            } else {
                shellOut(to: "cat \(context.location)")
            }
        }
        if failure {
            exit(1)
        }
    }
}

func printHelpMessage() {
    queuedPrintln("Usage:")
    queuedPrintln("")
    queuedPrintln("    $ cmdshelf")
    queuedPrintln("")
    queuedPrintln("Options:")
    queuedPrintln("    -h, --help")
    queuedPrintln("        Show this help message.")
    queuedPrintln("")
    queuedPrintln("Commands:")
    queuedPrintln("")
    queuedPrintln("    + blob - Manage blob commands (type `cmdshelf blob` for usage)")
    queuedPrintln("    + cat - concatenate and print commands")
    queuedPrintln("    + list - Show all registered commands (use --path to print absolute paths)")
    queuedPrintln("    + help - Show help message.")
    queuedPrintln("    + remote - Manage remote commands (type `cmdshelf remote` for usage)")
    queuedPrintln("    + run - Run command")
    queuedPrintln("    + update - Update all cloned repositories")
}

let help = command(SubCommandArgument()) { (subCommand) in
    if let subCommand = subCommand {
        queuedPrintln(subCommand.helpMessage)
        return
    }
    printHelpMessage()
}

let list = command(
    Flag("path", default: false, disabledName: "", description: "display absolute path instead of command name alias")
) { isPath in
    let config = try Configuration()
    try config.printAllCommands(displayType: isPath ? .absolutePath : .alias)
}

let remote = RemoteCommand()

let run = command(AliasParameterArgument()) { (aliasParam) in
    let config = try Configuration()
    let alias = aliasParam.alias.alias
    let remoteName = aliasParam.alias.remoteName
    let parameter = aliasParam.parameter
    // Search in blobs and remote
    guard let context = config.getContexts(for: alias, remoteName: remoteName).first else {
        queuedPrintlnError(Message.noSuchCommand(aliasParam.alias.originalValue))
        exit(1)
    }
    if context.location.hasPrefix("curl ") {
        shellOut(to: "bash <(\(context.location))", argument: parameter)
    } else {
        shellOut(to: context.location, argument: parameter)
    }
}

let update = command() {
    let config = try Configuration()
    config.cloneRemotesIfNeeded()
    config.updateRemotes()
}

let c = command(SubCommandConvertibleArgument())
{ (tuple) in
    func exec() throws {
        if let (subCommand, parser) = tuple {
            switch subCommand {
            case .blob: try blob.run(parser)
            case .cat: try cat.run(parser)
            case .list: try list.run(parser)
            case .remote: try remote.run(parser)
            case .run: try run.run(parser)
            case .help: try help.run(parser)
            case .update: try update.run(parser)
            }
        } else {
            // TODO: interactive mode
        }
    }

    do {
        try exec()
    } catch {
        queuedPrintlnError(error)
        printHelpMessage()
    }
}

c.run(version)
