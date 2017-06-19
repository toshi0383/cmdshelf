import Foundation

struct CmdshelfError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) {
        self.message = message
    }
    var description: String {
        return message
    }
}
