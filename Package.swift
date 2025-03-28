// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Agamotto",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "agamotto", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.6.3"),
        .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", exact: "1.8.1"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.0.2")
    ],
    targets: [
        .target(name: "GitHubClient", dependencies: [
            .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
        ], exclude: ["github-openapi-spec.yaml", "openapi-generator-config.yaml"]),
        
        // Swift Package Manager Stuff
        .target(name: "SwiftPackageManager"),
        .testTarget(name: "SwiftPackageManagerTests", dependencies: ["SwiftPackageManager"], resources: [.copy("sample-package-dump.json")]),
        
        // Core
        .target(
            name: "Core",
            dependencies: [
                "GitHubClient",
                "SwiftPackageManager",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(name: "CoreTests", dependencies: ["Core", "SwiftPackageManager"]),
        .executableTarget(name: "Run", dependencies: [
            .byName(name: "Core"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
    ]
)
