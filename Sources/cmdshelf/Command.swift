import Foundation
import Yams

struct Command: NodeRepresentable, AutoEquatable {
    enum CommandType {
        case remote, blob, swiftpm
    }
    let name: String
    let url: String
    let type: CommandType
    // MARK: NodeRepresentable
    func represented() throws -> Node {
        return try Node([name: Node(["url": url])])
    }
}

extension Array where Element == Command {
    mutating func remove(name: String) {
        let indice = filter { $0.name == name }.flatMap { self.index(of: $0) }.sorted().reversed()
        for i in indice {
            remove(at: i)
        }
    }
}
