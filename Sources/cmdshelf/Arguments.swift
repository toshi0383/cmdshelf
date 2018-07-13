import Foundation
import Reporter

// - MARK: Argument Types

struct Alias {
    let alias: String
    let remoteName: String?
    let originalValue: String
}

enum SubCommand: String {

    case blob, cat, help, list, remote, run, update

    init?(string: String) {
        if let v = SubCommand(rawValue: string) {
            self = v
        } else {
            switch string {
            case "ls":
                self = .list
            default:
                return nil
            }
        }
    }
}

// - MARK: ArgumentParser

final class ArgumentParser {

    var remainder: [String]

    init(args: [String]) {
        self.remainder = args
    }

    @discardableResult
    func shift() -> String? {
        if remainder.isEmpty {
            return nil
        }
        return remainder.removeFirst()
    }

    @discardableResult
    func shiftAll() -> [String] {
        let r = remainder
        remainder = []
        return r
    }
}

// - MARK: ArgumentDescriptor

/// ArgumetDescriptor parses values from given ArgumentParser
/// and convert them to associated ValueType.
protocol ArgumentDescriptor {
    associatedtype ValueType
    func parse(_ parser: ArgumentParser) throws -> ValueType
}

final class AliasParameterArgument: ArgumentDescriptor {

    typealias ValueType = (alias: Alias, parameters: [String])

    final class AliasParser {
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

final class VaradicAliasArgument: ArgumentDescriptor {
    func parse(_ parser: ArgumentParser) throws -> [Alias] {
        return parser.shiftAll().compactMap(AliasParameterArgument.AliasParser.parse)
    }
}

final class SubCommandArgument: ArgumentDescriptor {

    func parse(_ parser: ArgumentParser) throws -> SubCommand {
        guard let string = parser.shift() else {
            throw CmdshelfError("missing argument for SubCommand.")
        }
        if let subCommand = SubCommand(string: string) {
            return subCommand
        } else {
            throw CmdshelfError("invalid subcommand: \(string)")
        }
    }
}
