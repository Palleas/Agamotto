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
        // TODO: use github-generated client
        .target(name: "GitHubClient"),
        
        // Swift Package Manager Stuff
        .target(name: "SwiftPackageManager", resources: [.copy("dependency-filter.txt")]),
        .testTarget(name: "SwiftPackageManagerTests", dependencies: ["SwiftPackageManager"]),
        
        // Core
        .target(
            name: "Core",
            dependencies: [
                "GitHubClient", 
                "SwiftPackageManager",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(name: "CoreTests", dependencies: ["Core", "SwiftPackageManager"]),
        
        .executableTarget(name: "Run", dependencies: [
            .byName(name: "Core"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ])
    ]
)
