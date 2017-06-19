import Foundation
import PathKit
import Yams

private func commandsToDictionary(_ commands: [Command]) -> [String: [String: String]] {
    var r = [String: [String: String]]()
    for c in commands {
        r[c.name] = ["url": c.url]
    }
    return r
}

struct CmdshelfYaml: NodeRepresentable {
    var commands: [Command] = []
    var remotes: [Command] {
        return commands.filter { $0.type == .remote }
    }
    var blobs: [Command] {
        return commands.filter { $0.type == .blob }
    }
    var swiftpms: [Command] {
        return commands.filter { $0.type == .swiftpm }
    }
    mutating func addRemote(name: String, url: String) {
        commands.append(Command(name: name, url: url, type: .remote))
    }
    mutating func removeRemote(name: String) {
        guard remotes.map({ $0.name }).contains(name) else {
            return
        }
        commands.remove(name: name)
        // TODO: clean cloned repo
    }
    mutating func addBlob(name: String, url: String) {
        commands.append(Command(name: name, url: url, type: .blob))
    }
    mutating func removeBlob(name: String) {
        guard blobs.map({ $0.name }).contains(name) else {
            return
        }
        commands.remove(name: name)
    }
    mutating func addSwiftPM(name: String, url: String) {
        commands.append(Command(name: name, url: url, type: .swiftpm))
    }
    mutating func removeSwiftpm(name: String) {
        guard swiftpms.map({ $0.name }).contains(name) else {
            return
        }
        commands.remove(name: name)
        // TODO: clean cloned repo
    }
    func represented() throws -> Node {
        return [
            "remote": try Node(commandsToDictionary(remotes)),
            "blob": try Node(commandsToDictionary(blobs)),
            "swiftpm": try Node(commandsToDictionary(swiftpms)),
        ]
    }
    func blobURL(for name: String) -> String? {
        return blobs.filter { $0.name == name }.flatMap { $0.url }.first
    }
    func remoteURL(for name: String) -> String? {
        return remotes.filter { $0.name == name }.flatMap { $0.url }.first
    }
    func swiftpmURL(for name: String) -> String? {
        return swiftpms.filter { $0.name == name }.flatMap { $0.url }.first
    }
}
