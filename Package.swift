// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// var isDevelopment: Bool {
// 	return ProcessInfo.processInfo.environment["CMDSHELF_SWIFTPM_DEVELOPMENT"] == "YES"
// }

let package = Package(
    name: "cmdshelf",
    products: [
        .executable(name: "cmdshelf", targets: ["cmdshelf"]),
        .library(name: "Poxis", targets: ["Poxis"]),
    ],
    dependencies: {
        let deps: [Package.Dependency] = [
            .package(url: "https://github.com/toshi0383/Reporter.git", from: "0.3.2"),
            .package(url: "https://github.com/jpsim/Yams.git", from: "0.5.0")
        ]
        return deps
    }(),
    targets: [
        .target(name: "cmdshelf", dependencies: [
            "Poxis",
            "Reporter",
            "Yams",
        ]),
        .target(name: "Poxis", dependencies: [])
    ]
)
