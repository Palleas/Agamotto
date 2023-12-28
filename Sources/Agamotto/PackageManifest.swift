import Foundation
import GitHubClient

enum InvalidCloneUrlError: Error {
    case missingHost
    case invalidPath
}

public struct CloneUrl: Decodable {
    let value: URL

    public init(from decoder: Decoder) throws {
        self.value = try decoder.singleValueContainer().decode(URL.self)
    }

    var host: String {
        get throws {
            guard let host = value.host else {
                throw InvalidCloneUrlError.missingHost
            }

            return host
        }
    }

    var repoName: RepoName {
        get throws {
            let pieces = value.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
            guard pieces.count == 2 else {
                throw InvalidCloneUrlError.invalidPath
            }

            return RepoName(
                owner: String(pieces[0]),
                name: String(pieces[1].replacingOccurrences(of: ".git", with: ""))
            )
        }
    }
}

public struct Dependency: Decodable {
    public let name: String
    public let cloneURL: CloneUrl
    public let version: String?
}

struct CommandFailedError: Error {
    let terminationStatus: Int32
    let output: String
}

struct RuntimeError: LocalizedError {
    var errorDescription: String? { message }
    
    let message: String
}
enum PackageParsingError: Error {
    case invalidPayload
}

public func parsePackage(path: String) throws -> [Dependency] {
    guard let filterFilePath = Bundle.module.path(forResource: "dependency-filter", ofType: "txt") else {
        throw RuntimeError(message: "Unable to locate a file required to parse the output of the swift package registry command")
    }

    let cacheUrl = URL.cachesDirectory.appending(
        path: "com.perfectly-cooked.agamotto/\(UUID().uuidString)",
        directoryHint: .isDirectory
    )
    _ = try FileManager.default.createDirectory(at: cacheUrl, withIntermediateDirectories: true)

    let spmDumpPackageOutput = cacheUrl.appending(path: "dump.log").path()
    let jqFilterOutput = cacheUrl.appending(path: "jq-filter.log").path()
    let magicCommand = """
swift package dump-package --package-path \(path) | tee \(spmDumpPackageOutput) | jq -Mc -f \(filterFilePath) | tee \(jqFilterOutput)
"""
    
    let output = Pipe()
    let standardError = Pipe()

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", magicCommand]
    process.standardError = standardError
    process.standardOutput = output

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        throw CommandFailedError(
            terminationStatus: process.terminationStatus,
            output: try standardError.fileHandleForReading.readToEnd().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output"
        )
    }

    guard let data = try output.fileHandleForReading.readToEnd() else {
        throw PackageParsingError.invalidPayload
    }

    do {
        return try JSONDecoder().decode([Dependency].self, from: data)
    } catch is DecodingError {
        let stderr = try standardError.fileHandleForReading.readToEnd().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output"
        throw RuntimeError(message: """
Parsing manifest failed with the following error message:

> \(stderr)

This an happen when the response format of the `swift package dump-package` command has changed.
Command output is available at \(spmDumpPackageOutput)
JQ result filter is available at \(jqFilterOutput)
""")

    }
}
