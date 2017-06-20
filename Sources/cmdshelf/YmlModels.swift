import Foundation
import Yams

struct Blob: NodeRepresentable, AutoEquatable {
    let name: String
    let url: String
    // MARK: NodeRepresentable
    func represented() throws -> Node {
        return try Node([name: Node(["url": url])])
    }
}

struct Repository: NodeRepresentable, AutoEquatable {
    let name: String
    let url: String
    let tag: String?
    let branch: String?
    // MARK: NodeRepresentable
    func represented() throws -> Node {
        var node = ["url": url]
        if let tag = tag {
            node["tag"] = tag
        }
        if let branch = branch {
            node["branch"] = branch
        }
        return try Node([name: Node(node)])
    }
}

extension Array where Element: Equatable {
    func find(_ condition: ((Element) -> Bool)) -> Element? {
        return filter(condition).first
    }
    mutating func remove(condition: ((Element) -> Bool)) {
        if let e = find(condition), let index = index(of: e) {
            remove(at: index)
        }
    }
}
