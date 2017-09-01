import Foundation

enum Message {
    static let COMMAND = "[remoteName:]my/script"
    static func noSuchCommand(_ commandName: String) -> String {
        return "cmdshelf: \(commandName): No such command"
    }
}
