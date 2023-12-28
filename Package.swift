// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Agamotto",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "agamotto", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.1.2"),
    ],
    targets: [
        .target(name: "GitHubClient"),
        .target(
            name: "Agamotto",
            dependencies: [.byName(name: "GitHubClient")],
            resources: [.copy("dependency-filter.txt")]
        ),
        .executableTarget(name: "Run", dependencies: [
            .byName(name: "Agamotto"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ])
    ]
)
