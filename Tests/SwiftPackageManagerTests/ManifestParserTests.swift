import XCTest
import SwiftPackageManager

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

final class ManifestParserTests: XCTestCase {
    func testParsePackage_validOutput() throws {
        let parser = ManifestParser(
            runner: StaticCommandRunner.withOutput("""
[
    { "name": "vapor", "cloneURL": "https://github.com/vapor/vapor.git", "version": "1.2.3" },
    { "name": "fluent", "cloneURL": "https://github.com/vapor/fluent.git", "version": null }
]
"""),
            cachesDirectory: temporaryDirectory()
        )
        
        do {
            let dependencies = try parser.parsePackage(path: temporaryDirectoryPath())
            XCTAssertEqual(dependencies, [
                Dependency(name: "vapor", cloneURL: CloneUrl(url: URL(string: "https://github.com/vapor/vapor.git")!), version: "1.2.3"),
                Dependency(name: "fluent", cloneURL: CloneUrl(url: URL(string: "https://github.com/vapor/fluent.git")!), version: nil)
            ])
        } catch let error {
            throw error
        }
        
    }
    
    func testParsePackage_invalidOutput() throws {
        let parser = ManifestParser(
            runner: StaticCommandRunner.withOutput("[{ name: null, cloneURL: null, version: null }]"),
            cachesDirectory: temporaryDirectory()
        )
        
        XCTAssertThrowsError(try parser.parsePackage(path: temporaryDirectoryPath())) { error in
            guard let runtimeError = error as? RuntimeError else { return XCTFail() }
            
            XCTAssertTrue(runtimeError.message.contains("dump.log"))
            XCTAssertTrue(runtimeError.message.contains("jq-filter.log"))
        }
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
