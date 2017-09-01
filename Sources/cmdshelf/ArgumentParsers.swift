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
        return string.components(separatedBy: " ").dropFirst().joined()
    }
}

struct VaradicAliasArgument: ArgumentDescriptor {
    typealias ValueType = [Alias]
    let name: String = "[COMMAND ...]"
    let description: String? = "[[remoteName:]my/command ...]"
    let type: ArgumentType = .argument
    func parse(_ parser: ArgumentParser) throws -> ValueType {
        return parser.shiftAll().flatMap(AliasParser.parse)
    }
}

struct AliasParameterArgument: ArgumentDescriptor {
    typealias ValueType = (alias: Alias, parameter: String?)
    let name: String = "COMMAND"
    let description: String? = "\"[remoteName:]my/command [parameter ...]\"\n    -   double or single quoted when passing arguments. e.g. `cmdshelf run \"myscript --option someargument\"\n    -   To avoid name collision, add remote name separated by \":\". e.g. `cmdshelf run my-remote:my/script`"
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
