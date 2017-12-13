import Foundation
import Reporter

enum Message {
    static let COMMAND = "[remoteName:]my/script"
    static func noSuchCommand(_ commandName: String) -> String {
        return "cmdshelf: \(commandName): No such command"
    }
}

func bold<T: CustomStringConvertible>(_ t: T) -> String {
    return "\(ANSI.bold.description)\(t.description)\(ANSI.reset)"
}

extension SubCommand {

    var shortDescription: String {
        switch self {
        case .blob: return "manage blob commands"
        case .cat: return "concatenate and print command files"
        case .help: return "show help messages"
        case .list: return "list commands"
        case .remote: return "manage remotes"
        case .run: return "execute a command"
        case .update: return "update cloned repositories"
        }
    }

    var helpMessage: String {

        let nameSection = """
            \(bold("NAME"))
                \(bold(self.rawValue)) -- \(self.shortDescription)
            """

        let headerAndNameSection = """

                                 Cmdshelf Manual
        \(nameSection)

        """

        let synopsis = bold("SYNOPSIS")
        let description = bold("DESCRIPTION")
        let commands = bold("COMMANDS")

        let footerSection = """
        cmdshelf \(version)          December 13, 2017               MIT

        """

        switch self {
        case .blob: return """
            \(headerAndNameSection)
            \(synopsis)
                `cmdshelf blob` <command> [<args>]

            \(description):
                The `blob` subcommand manages blobs.

            \(commands):
                \(bold("add")) <name> <blob URL|local file path>
                    Add a remote file URL or a local file path as a blob named \(bold("<name>")).

                \(bold("remove")) <name>
                    Remove blob named \(bold("<name>")).

            \(footerSection)
            """
        case .cat: return """
            \(headerAndNameSection)
            \(synopsis)
                cmdshelf cat [[<remoteName>:]<command>]

            \(description):
                The `cat` subcommand reads commands script files sequentially,
                writing them to the standard output.

            \(footerSection)
            """
        case .list: return """
            \(headerAndNameSection)
            \(synopsis)
                cmdshelf list [--path]

            \(description):
                The `list` subcommand lists all commands from remotes and blobs.
                `--path` prints absolute path to each commands.

            \(footerSection)
            """
        case .remote: return """
            \(headerAndNameSection)
            \(synopsis)
                cmdshelf remote <command> [<args>]

            \(description):
                The `remote` subcommand manages remotes.
                See `cmdshelf help remote` for usage.

            \(commands):
                \(bold("add")) <name> <git URL>
                    Add a repository as a remote named \(bold("<name>")).

                \(bold("remove")) <name>
                    Remove remote named \(bold("<name>")).

            \(footerSection)
            """
        case .run: return """
            \(headerAndNameSection)
            \(synopsis)
                cmdshelf run [<remoteName>:]<command> [<args>]

            \(description):
                The `run` subcommand receives command-alias and whitespace separated list of parameters.

            \(footerSection)
            """
        case .update:
            let remoteDirPath = "~/.cmdshelf/remote"
            let removeInstruction = "rm -rf \(remoteDirPath)"
            return """
            \(headerAndNameSection)
            \(synopsis)
                cmdshelf update

            \(description):
                The `update` subcommand updates all cloned repositories.
                Cmdshelf automatically clones repositories under \(bold(remoteDirPath)).
                Please run \(bold(removeInstruction)) and re-try update when it keeps
                failing.

            \(footerSection)
            """
        default: return ""
        }
    }
}
