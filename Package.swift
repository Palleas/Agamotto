// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Agamotto",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "agamotto", targets: ["Run"])
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .exact("1.1.2")),
    ],
    targets: [
        .target(name: "GitHubClient"),
        .target(name: "Agamotto", dependencies: [.byName(name: "GitHubClient")]),
        .executableTarget(name: "Run", dependencies: [
            .byName(name: "Agamotto"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ])
    ]
)
