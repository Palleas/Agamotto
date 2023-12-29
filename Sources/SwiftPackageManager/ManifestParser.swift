import Foundation

struct CommandFailedError: Error {
    let terminationStatus: Int
    let output: String
}

struct RuntimeError: LocalizedError {
    var errorDescription: String? { message }
    
    let message: String
}

enum PackageParsingError: Error {
    case invalidPayload
}

public struct ManifestParser {
    
    let runner: CommandRunner
    let cachesDirectory: URL
    
    public init(runner: CommandRunner, cachesDirectory: URL) {
        self.runner = runner
        self.cachesDirectory = cachesDirectory
    }
    
    public func parsePackage(path: String) throws -> [Dependency] {
        guard let filterFilePath = Bundle.module.path(forResource: "dependency-filter", ofType: "txt") else {
            throw RuntimeError(message: "Unable to locate a file required to parse the output of the swift package registry command")
        }
        
        let cacheUrl = cachesDirectory.appending(
            path: "com.perfectly-cooked.agamotto/\(UUID().uuidString)",
            directoryHint: .isDirectory
        )
        _ = try FileManager.default.createDirectory(at: cacheUrl, withIntermediateDirectories: true)
        
        let spmDumpPackageOutput = cacheUrl.appending(path: "dump.log").path()
        let jqFilterOutput = cacheUrl.appending(path: "jq-filter.log").path()
        let magicCommand = """
swift package dump-package --package-path \(path) | tee \(spmDumpPackageOutput) | jq -Mc -f \(filterFilePath) | tee \(jqFilterOutput)
"""

        let dumpPackageCommandResult = try runner.run(command: magicCommand)
        
        guard dumpPackageCommandResult.isSuccess else {
            throw CommandFailedError(
                terminationStatus: dumpPackageCommandResult.terminationStatus,
                output: try dumpPackageCommandResult.standardOutput().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output"
            )
        }
        
        guard let data = try dumpPackageCommandResult.standardOutput() else {
            throw PackageParsingError.invalidPayload
        }
        
        do {
            return try JSONDecoder().decode([Dependency].self, from: data)
        } catch is DecodingError {
            let stderr = try dumpPackageCommandResult.standardError().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output"
            throw RuntimeError(message: """
Parsing manifest failed with the following error message:

> \(stderr)

This an happen when the response format of the `swift package dump-package` command has changed.
Command output is available at \(spmDumpPackageOutput)
JQ result filter is available at \(jqFilterOutput)
""")
            
        }
    }
}
