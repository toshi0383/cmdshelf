import Commander
import Foundation

struct Alias {
    let alias: String
    let remoteName: String?
    var fullAlias: String {
        if let remoteName = remoteName {
            return "\(remoteName):\(alias)"
        } else {
            return alias
        }
    }
    static let empty = Alias(alias: "", remoteName: nil)
}

class AliasParser {
    static func parse(_ string: String) -> Alias {
        let components = string.components(separatedBy: " ")
        guard let _alias = components.first else {
            return .empty
        }
        let alias: String
        let remoteName: String?
        if _alias.contains(":") {
            remoteName = _alias.components(separatedBy: ":").first!
            alias = _alias.components(separatedBy: ":").dropFirst().joined()
        } else {
            alias = _alias
            remoteName = nil
        }
        return Alias(alias: alias, remoteName: remoteName)
    }
}

class ParameterParser {
    static func parse(_ string: String) -> String {
        return string.components(separatedBy: " ").dropFirst().joined()
    }
}

struct VaradicAliasArgument: ArgumentDescriptor {
    typealias ValueType = [Alias]
    let name: String = "[COMMAND ...]"
    let description: String? = nil
    let type: ArgumentType = .argument
    func parse(_ parser: ArgumentParser) throws -> ValueType {
        let remainder = parser.remainder
        for _ in remainder {
            _ = parser.shift()
        }
        return remainder.map(AliasParser.parse)
    }
}

struct AliasParameterArgument: ArgumentDescriptor {
    typealias ValueType = (alias: Alias, parameter: String)
    let name: String = "COMMAND"
    let description: String? = "command name alias\n double or single quoted when passing arguments. e.g. `cmdshelf run \"myscript --option someargument\"\nTo avoid name collision, add remote name separated by :. e.g. `cmdshelf run my-remote:my/script`"
    let type: ArgumentType = .argument
    func parse(_ parser: ArgumentParser) throws -> ValueType {
        guard let string = parser.shift() else {
            throw ArgumentError.missingValue(argument: name)
        }
        return (AliasParser.parse(string), ParameterParser.parse(string))
    }
}
