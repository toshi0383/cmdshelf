import Commander
import Foundation

struct Alias {
    let alias: String
    let remoteName: String?
    let originalValue: String
}

private class AliasParser {
    static func parse(_ string: String) -> Alias? {
        guard !string.isEmpty else {
            return nil
        }
        // Get "remote:my/script" part.
        // `"".components(separatedBy: " ").count` is 1, so force unwrap.
        let _alias  = string.components(separatedBy: " ").first!
        let alias: String
        let remoteName: String?
        if _alias.contains(":") {
            remoteName = _alias.components(separatedBy: ":").first!
            alias = _alias.components(separatedBy: ":").dropFirst().joined()
        } else {
            alias = _alias
            remoteName = nil
        }
        return Alias(alias: alias, remoteName: remoteName, originalValue: _alias)
    }
}

private class ParameterParser {
    static func parse(_ string: String) -> String? {
        guard !string.isEmpty else {
            return nil
        }
        return string.components(separatedBy: " ").dropFirst().joined(separator: " ")
    }
}

struct VaradicAliasArgument: ArgumentDescriptor {
    typealias ValueType = [Alias]
    let name: String = "[\(Message.COMMAND) ...]"
    let description: String? = nil
    let type: ArgumentType = .argument
    func parse(_ parser: ArgumentParser) throws -> ValueType {
        return parser.shiftAll().flatMap(AliasParser.parse)
    }
}

struct AliasParameterArgument: ArgumentDescriptor {
    typealias ValueType = (alias: Alias, parameter: String?)
    let name: String = "\"\(Message.COMMAND) [parameter ...]\""
    let description: String? = "Double or single quote when passing arguments. e.g. `cmdshelf run \"myscript --option someargument\""
    let type: ArgumentType = .argument
    func parse(_ parser: ArgumentParser) throws -> ValueType {
        guard let string = parser.shift() else {
            throw ArgumentError.missingValue(argument: name)
        }
        guard let alias = AliasParser.parse(string) else {
            throw ArgumentError.missingValue(argument: "COMMAND")
        }
        return (alias, ParameterParser.parse(string))
    }
}

// MARK: - Commander extension
extension ArgumentParser {
    func shiftAll() -> [String] {
        let _remainder = remainder
        for _ in remainder {
            _ = shift()
        }
        return _remainder
    }
}
