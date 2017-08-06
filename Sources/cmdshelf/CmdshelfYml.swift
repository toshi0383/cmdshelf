import Foundation
import PathKit
import Yams

private func repositoriesToDictionary(_ repositories: [Repository]) -> [String: [String: String]] {
    var r = [String: [String: String]]()
    for b in repositories {
        var node = ["url": b.url]
        if let branch = b.branch {
            node["branch"] = branch
        }
        if let tag = b.tag {
            node["tag"] = tag
        }
        r[b.name] = node
    }
    return r
}

private func blobsToDictionary(_ blobs: [Blob]) -> [String: [String: String]] {
    var r = [String: [String: String]]()
    for b in blobs {
        var d: [String: String] = [:]
        if let url = b.url {
            d["url"] = url
        }
        if let localPath = b.localPath {
            d["localPath"] = localPath
        }
        r[b.name] = d
    }
    return r
}

struct CmdshelfYaml: NodeRepresentable {
    var remotes: [Repository] = []
    var blobs: [Blob] = []
    mutating func removeRemote(name: String) {
        remotes.remove { $0.name == name }
        // TODO: clean cloned repo
    }
    mutating func removeBlob(name: String) {
        blobs.remove { $0.name == name }
    }
    func represented() throws -> Node {
        return [
            "remote": try Node(repositoriesToDictionary(remotes)),
            "blob": try Node(blobsToDictionary(blobs)),
        ]
    }
    func blobLocalPath(for name: String) -> String? {
        return blobs.filter { $0.name == name }.flatMap { $0.localPath }.first
    }
    func blobURL(for name: String) -> String? {
        return blobs.filter { $0.name == name }.flatMap { $0.url }.first
    }
    func remoteURL(for name: String) -> String? {
        return remotes.filter { $0.name == name }.flatMap { $0.url }.first
    }
}
