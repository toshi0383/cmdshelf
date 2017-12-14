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
        let cmdshelf = bold("cmdshelf")
        let remoteDirPath = "~/.cmdshelf/remote"


        let headerSection = """

                                 Cmdshelf Manual
        """

        let nameSection = """
        \(bold("NAME"))
            \(bold(self.rawValue)) -- \(self.shortDescription)
        """

        let cmdshelfNameSection = """
        \(bold("NAME"))
            \(cmdshelf) -- Manage your scripts like a bookshelf.📚
        """

        let synopsis = bold("SYNOPSIS")
        let description = bold("DESCRIPTION")
        let commands = bold("COMMANDS")

        let footerSection = """
        cmdshelf \(version)          December 13, 2017               MIT

        """

        switch self {
        case .blob: return """
            \(headerSection)
            \(nameSection)

            \(synopsis)
                `cmdshelf blob` <command> [<args>]

            \(description)
                The \(bold("blob")) subcommand manages blobs.

            \(commands)
                \(bold("add")) <name> <blob URL|local file path>
                    Add a remote file URL or a local file path as a blob named \(bold("<name>")).

                \(bold("list"))
                    List blobs.

                \(bold("remove")) <name>
                    Remove blob named \(bold("<name>")).

            \(footerSection)
            """

        case .cat: return """
            \(headerSection)
            \(nameSection)

            \(synopsis)
                cmdshelf cat [[<remoteName>:]<command>]

            \(description)
                The \(bold("cat")) subcommand reads commands script files sequentially,
                writing them to the standard output.

            \(footerSection)
            """

        case .list: return """
            \(headerSection)
            \(nameSection)

            \(synopsis)
                cmdshelf list [--path]

            \(description)
                The \(bold("list")) subcommand lists all commands from remotes and blobs.
                \(bold("--path")) prints absolute path to each commands.

            \(footerSection)
            """

        case .remote: return """
            \(headerSection)
            \(nameSection)

            \(synopsis)
                cmdshelf remote <command> [<args>]

            \(description):
                The \(bold("remote")) subcommand manages remotes.

            \(commands):
                \(bold("add")) <name> <git URL>
                    Add a repository as a remote named \(bold("<name>")).

                \(bold("list"))
                    List remotes.

                \(bold("remove")) <name>
                    Remove remote named \(bold("<name>")).

            \(footerSection)
            """

        case .run: return """
            \(headerSection)
            \(nameSection)

            \(synopsis)
                cmdshelf run [<remoteName>:]<command> [<args>]

            \(description)
                The \(bold("run")) subcommand receives command-alias and whitespace
                separated list of parameters.

            \(bold("AVOIDING NAMESPACE CONFLICT"))
                The \(bold("run")) subcommand picks-up first command matches the command name.
                If you end-up with multiple same command names from different remotes,
                add \(bold("<remoteName>:")) before the \(bold("<command>")).
                    e.g. cmdshelf run myRemote:echo-sd hello

            \(footerSection)
            """

        case .update:
            let removeInstruction = "rm -rf \(remoteDirPath)"
            return """
            \(headerSection)
            \(nameSection)

            \(synopsis)
                cmdshelf update

            \(description)
                The \(bold("update")) subcommand updates all cloned repositories.
                Cmdshelf automatically clones repositories under \(bold(remoteDirPath)).
                Please run \(bold(removeInstruction)) and re-try update when it keeps
                failing.

            \(footerSection)
            """

        case .help: // Manual Page for cmdshelf itself.

            let cmdshelfYmlPath = bold("~/.cmdshelf.yml")
            let workspace = bold("WORKSPACE")
            let options = bold("OPTIONS")
            let subcommands = bold("SUB-COMMANDS")

            return """
            \(headerSection)
            \(cmdshelfNameSection)

            \(synopsis)
                cmdshelf <sub-command> [<parameter>...]

            \(description)
                The \(cmdshelf) utility manages your remote scripts like a bookshelf.

            \(options)
                -h, --help
                    Show this help message.
                    Type \(bold("cmdshelf help <sub-command>")) to see more detailed
                    manual page for each sub-commands.

            \(subcommands)
                \(bold("blob"))   - Manage blob commands.
                \(bold("cat"))    - Concatenate and print sourcecodes of commands.
                \(bold("help"))   - Show help message.
                \(bold("list"))   - Show all registered commands.
                \(bold("remote")) - Manage remote commands.
                \(bold("run"))    - Execute command.
                \(bold("update")) - Update cloned repositories.

            \(workspace)
                \(cmdshelfYmlPath)
                    Your current configuration is stored here.
                    \(cmdshelf) reads this file everytime it launches, writing on exit.
                    Feel free to modify entries and run \(bold("cmdshelf update")) to keep in sync.

                \(bold(remoteDirPath))
                    All repositories are cloned under this directory.

            \(footerSection)
            """

        }
    }
}
