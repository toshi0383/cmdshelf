import Commander
import PathKit
import Foundation
import Reporter

let version = "0.6.0"

let group = Group { group in
    group.addCommand("list", command(
        Flag("path", disabledName: "", description: "display absolute path instead of command alias name", default: false)
        ) { isPath in
        let config = try Configuration()
        try config.printAllCommands(displayType: isPath ? .absolutePath : .alias)
    })
    group.addCommand("remote", RemoteCommand())
    group.addCommand("blob", BlobCommand())
    group.addCommand("cat", "concatenate and print commands", command(
        VaradicAliasArgument()
    ) { (aliases) in
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
    })
    group.addCommand("run", "Run command", command(
        AliasParameterArgument()
    ) { (aliasParam) in
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
    })
    group.addCommand("update", command() {
        let config = try Configuration()
        config.cloneRemotesIfNeeded()
        config.updateRemotes()
    })
}

group.run(version)
