import Foundation

struct CacheKind {
    let filename: String
}

extension CacheKind {
    static let swiftPackageDirectoryDump = CacheKind(filename: "dump.log")
    
    static let jqFilterResult = CacheKind(filename: "jq-filter.log")
}

private extension URL {
    func path(for kind: CacheKind) -> String {
        #if os(Linux)
        appendingPathComponent(kind.filename).path
        #else
        appending(path: kind.filename).path()
        #endif
    }
}


public struct RuntimeError: Error {
    public let message: String
}

public struct ManifestParser {

    let runner: CommandRunning
    let cachesDirectory: URL

    public init(runner: CommandRunning, cachesDirectory: URL) {
        self.runner = runner
        self.cachesDirectory = cachesDirectory
    }

    public func parsePackage(path: String) throws -> [Dependency] {
        guard let filterFilePath = Bundle.module.path(forResource: "dependency-filter", ofType: "txt") else {
            throw RuntimeError(message: "Unable to locate a file required to parse the output of the swift package registry command")
        }

        let cacheUrl = try createCacheEntry()
        let spmDumpPackageOutput = cacheUrl.path(for: .swiftPackageDirectoryDump)
        let jqFilterOutput = cacheUrl.path(for: .jqFilterResult)
        
        let magicCommand = """
swift package dump-package --package-path \(path) | tee \(spmDumpPackageOutput) | jq -Mc -f \(filterFilePath) | tee \(jqFilterOutput)
"""

        let dumpPackageCommandResult = try runner.run(command: magicCommand)

        guard dumpPackageCommandResult.isSuccess else {
            // TODO: write a better error here
            throw RuntimeError(
                message: "An error occured: " + (try dumpPackageCommandResult.standardOutput().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output")
            )
        }

        guard let data = try dumpPackageCommandResult.standardOutput() else {
            throw RuntimeError(message: "There was an error while analyzing the package")
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
    
    func createCacheEntry() throws -> URL {
        #if os(Linux)
        let cacheUrl = cachesDirectory.appendingPathComponent(
            "com.perfectly-cooked.agamotto/\(UUID().uuidString)",
            isDirectory: true
        )
        #else
        let cacheUrl = cachesDirectory.appending(
            path: "com.perfectly-cooked.agamotto/\(UUID().uuidString)",
            directoryHint: .isDirectory
        )
        #endif
        _ = try FileManager.default.createDirectory(at: cacheUrl, withIntermediateDirectories: true)
        
        return cacheUrl
    }
}
