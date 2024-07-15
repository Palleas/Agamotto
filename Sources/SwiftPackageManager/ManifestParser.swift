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
    let isVerbose: Bool

    public init(runner: CommandRunning, cachesDirectory: URL, isVerbose: Bool) {
        self.runner = runner
        self.cachesDirectory = cachesDirectory
        self.isVerbose = isVerbose
    }

    public func parsePackage(path: String) throws -> [Dependency] {
        let cacheUrl = try createCacheEntry()
        let spmDumpPackageOutput = cacheUrl.path(for: .swiftPackageDirectoryDump)
        
        let magicCommand = "swift package dump-package --package-path \(path)"

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
            let response = try JSONDecoder().decode(PackageDumpResponse.self, from: data)
            return try response.dependencies.map { dependency in
                guard let sourceControl = dependency.sourceControl.first else { throw RuntimeError(message: "Missing source control entry") }
                
                guard let urlString = sourceControl.location.remote.first?["urlString"].flatMap(URL.init(string:)) else { throw RuntimeError(message: "Missing or invalid remote url") }
                
                return Dependency(
                    name: sourceControl.identity,
                    cloneURL: CloneUrl(url: urlString),
                    version: sourceControl.requirement.exact?.first
                )
            }
        } catch is DecodingError {
            let stderr = try dumpPackageCommandResult.standardError().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output"
            throw RuntimeError(message: """
Parsing manifest failed with the following error message:

> \(stderr)

This an happen when the response format of the `swift package dump-package` command has changed.
Command output is available at \(spmDumpPackageOutput)
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
