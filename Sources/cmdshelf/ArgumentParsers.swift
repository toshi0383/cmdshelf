import Foundation
import Reporter

struct Alias {
    let alias: String
    let remoteName: String?
    let originalValue: String
}

final class ArgumentParser {

    var remainder: [String]

    init(args: [String]) {
        self.remainder = args
    }

    func shift() -> String? {
        if remainder.isEmpty {
            return nil
        }
        return remainder.removeFirst()
    }

    func shiftAll() -> [String] {
        let r = remainder
        remainder = []
        return r
    }
}

protocol ArgumentDescriptor {
    associatedtype ValueType
    func parse(_ parser: ArgumentParser) throws -> ValueType
}

private class AliasParser {
    static func parse(_ string: String) -> Alias? {
        guard !string.isEmpty else {
            return nil
        }

        // Get "remote:my/script" part.
        //
        // NOTE:
        // - `"".components(separatedBy: " ").count` is 1, so force unwrap is safe.
        let alias: String
        let remoteName: String?
        if string.contains(":") {
            remoteName = string.components(separatedBy: ":").first!
            alias = string.components(separatedBy: ":").dropFirst().joined()
        } else {
            alias = string
            remoteName = nil
        }

        return Alias(alias: alias, remoteName: remoteName, originalValue: string)
    }
}

final class VaradicAliasArgument: ArgumentDescriptor {
    func parse(_ parser: ArgumentParser) throws -> [Alias] {
        return parser.shiftAll().flatMap(AliasParser.parse)
    }
}

final class AliasParameterArgument: ArgumentDescriptor {

    typealias ValueType = (alias: Alias, parameters: [String])

    func parse(_ parser: ArgumentParser) throws -> ValueType {
        guard let string = parser.shift() else {
            throw CmdshelfError("invalid arguments")
        }
        guard let alias = AliasParser.parse(string) else {
            throw CmdshelfError("invalid arguments")
        }
        return (alias, parser.shiftAll())
    }
}

struct SubCommandArgument: ArgumentDescriptor {

    func parse(_ parser: ArgumentParser) throws -> SubCommand {
        guard let string = parser.shift() else {
            throw CmdshelfError("missing argument for SubCommand.")
        }
        if let subCommand = SubCommand(rawValue: string) {
            return subCommand
        } else {
            throw CmdshelfError("invalid argument: \(string)\nPass a correct SubCommand name.")
        }
    }
}

enum SubCommand: String {

    case run, list, remote, blob, cat, update, help

    var possiblyHasManPage: Bool {
        return [.list].contains(self)
    }
}
