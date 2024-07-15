// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sample-package",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", exact: "1.4.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", revision: "e80046bc806e27b9cc0b052eb325a04664de66ae"),
        .package(url: "https://github.com/apple/swift-atomics.git", branch: "main"),
    ]
)
