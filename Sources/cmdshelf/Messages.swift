import Foundation

enum Message {
    static func noSuchCommand(_ commandName: String) -> String {
        return "cmdshelf: \(commandName): No such command"
    }
}
