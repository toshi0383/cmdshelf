import Commander
import PathKit
import Foundation
import Reporter

let version = "0.9.1"

//
// - MARK: Setup
//
do {
    var env = ProcessInfo.processInfo.environment

    // Disable terminal prompts in git. This will make git error out and return
    // when it needs a user/pass etc instead of hanging the terminal (SR-3981).
    env["GIT_TERMINAL_PROMPT"] = "0"
}

//
// - MARK: Execution
//
let blob = BlobCommand()

let cat = command(VaradicAliasArgument()) { (aliases) in
    if aliases.isEmpty {
        exit(shellOut(to: "cat"))
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
                if shellOut(to: context.location) > 0 {
                    failure = true
                }
            } else {
                if shellOut(to: "cat \(context.location)") > 0 {
                    failure = true
                }
            }
        }
        if failure {
            throw CmdshelfError()
        }
    }
}

func printHelpMessage() {
    queuedPrintln(SubCommand.help.helpMessage)
}

let help = command(SubCommandArgument()) { (subCommand) in
    if let subCommand = subCommand {
        if subCommand.possiblyHasManPage {
            if spawnPager(cmdString: "man cmdshelf-\(subCommand.rawValue)") != 0 {
                queuedPrintln(subCommand.helpMessage)
            }
        } else {
            queuedPrintln(subCommand.helpMessage)
        }
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
    let parameters = aliasParam.parameters
    // Search in blobs and remote
    guard let context = config.getContexts(for: alias, remoteName: remoteName).first else {
        queuedPrintlnError(Message.noSuchCommand(aliasParam.alias.originalValue))
        throw CmdshelfError()
    }
    let singleQuoted = parameters.map { "\'\($0)\'" }.joined(separator: " ")
    if context.location.hasPrefix("curl ") {
        exit(shellOut(to: "bash <(\(context.location))", argument: singleQuoted))
    } else {
        exit(shellOut(to: context.location, argument: singleQuoted))
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
            help.run()
        }
    }

    do {
        try exec()

    } catch let error as CmdshelfError {
        if let msg = error.message {
            queuedPrintlnError(msg)
        }
        exit(1)

    } catch {
        queuedPrintlnError(error)
        exit(1)
    }
}

c.run(version)
