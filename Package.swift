// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Agamotto",
    platforms: [.macOS(.v12)],
    dependencies: [],
    targets: [
        .target(name: "GitHubClient"),
        .target(name: "Agamotto", dependencies: [.byName(name: "GitHubClient")]),
        .executableTarget(name: "Run", dependencies: [.byName(name: "Agamotto")])
    ]
)
