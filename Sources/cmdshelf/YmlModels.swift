import Foundation
import Yams

struct Blob: NodeRepresentable, AutoEquatable {
    let name: String
    let url: String?
    let localPath: String?
    init(name: String, url: String? = nil, localPath: String? = nil) {
        if (url == nil && localPath == nil) {
            assertionFailure("url and localPath cannot be nil at the same time.")
        }
        self.name = name
        self.url = url
        self.localPath = localPath
    }
    // MARK: NodeRepresentable
    func represented() throws -> Node {
        if let url = url {
            return try Node([name: Node(["url": url])])
        }
        return try Node([name: Node(["localPath": localPath!])])
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
