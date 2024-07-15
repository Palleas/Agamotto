import XCTest
import SwiftPackageManager
import Foundation

private struct StaticCommandRunner: CommandRunning {
    let result: CommandRunResult
    
    func run(command: String) throws -> CommandRunResult {
        result
    }
    
    static func withOutput(_ content: String) -> CommandRunning {
        StaticCommandRunner(result: CommandRunResult(
            standardOutput: { Data(content.utf8) },
            standardError: { nil },
            terminationStatus: 0)
        )
    }
}

private struct OutputError: LocalizedError {
    let message: String
    
    var errorDescription: String? { message }
}

private func readOutput(named name: String) throws -> Data {
    guard let path = Bundle.module.path(forResource: name, ofType: "json") else {
        throw OutputError(message: "Fixture \(name) does not exist")
    }
    
    return try Data(contentsOf: URL(fileURLWithPath: path))
}

final class ManifestParserTests: XCTestCase {
    func testParsePackage_validOutput() throws {
        let parser = ManifestParser(
            runner: try StaticCommandRunner.withOutput(String(decoding: readOutput(named: "sample-package-dump"), as: UTF8.self)),
            cachesDirectory: temporaryDirectory(),
            isVerbose: true
        )
        
        let dependencies = try parser.parsePackage(path: temporaryDirectoryPath())
        XCTAssertEqual(dependencies, [
            Dependency(
                name: "swift-argument-parser",
                cloneURL: CloneUrl(url: URL(string: "https://github.com/apple/swift-argument-parser.git")!),
                version: "1.4.0"
            ),
            Dependency(
                name: "swift-log",
                cloneURL: CloneUrl(url: URL(string: "https://github.com/apple/swift-log.git")!),
                version: nil
            ),
            Dependency(
                name: "swift-openapi-runtime",
                cloneURL: CloneUrl(url: URL(string: "https://github.com/apple/swift-openapi-runtime")!),
                version: nil
            ),
            Dependency(
                name: "swift-atomics",
                cloneURL: CloneUrl(url: URL(string: "https://github.com/apple/swift-atomics.git")!),
                version: nil
            ),
        ])
    }
}

private func temporaryDirectory() -> URL {
#if os(Linux)
    FileManager.default.temporaryDirectory
#else
    URL.temporaryDirectory
#endif
    
}

private func temporaryDirectoryPath() -> String {
#if os(Linux)
    temporaryDirectory().path
#else
    temporaryDirectory().path()
#endif
}
