// swift-tools-version:3.1

import Foundation
import PackageDescription

var isDevelopment: Bool {
	return ProcessInfo.processInfo.environment["SWIFTPM_DEVELOPMENT"] == "YES"
}

let package = Package(
    name: "cmdshelf",
    dependencies: {
        let deps: [Package.Dependency] = [
            .Package(url: "https://github.com/toshi0383/Commander.git", majorVersion: 0),
            .Package(url: "https://github.com/toshi0383/PathKit.git", majorVersion: 0),
            .Package(url: "https://github.com/toshi0383/Reporter.git", majorVersion: 0),
            .Package(url: "https://github.com/jpsim/Yams.git", majorVersion: 0)
        ]
        return deps
    }(),
    exclude: ["Resources/SourceryTemplates"]
)

