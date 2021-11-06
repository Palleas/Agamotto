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
    public let version: String
}

struct CommandFailedError: Error {
    let terminationStatus: Int32
    let output: String
}

enum PackageParsingError: Error {
    case invalidPayload
}

public func parsePackage(path: String) throws -> [Dependency] {
    let magicCommand = """
swift package dump-package --package-path \(path) | jq -Mc "[ .dependencies[].scm[0] | { name: .identity, url: .location, version: .requirement.exact[0] }]"
"""
    let output = Pipe()
    let error = Pipe()

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", magicCommand]
    process.standardError = error
    process.standardOutput = output

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        throw CommandFailedError(
            terminationStatus: process.terminationStatus,
            output: try error.fileHandleForReading.readToEnd().map({ String(decoding: $0, as: UTF8.self) }) ?? "No output"
        )
    }

    guard let data = try output.fileHandleForReading.readToEnd() else {
        throw PackageParsingError.invalidPayload
    }

    return try JSONDecoder().decode([Dependency].self, from: data)
}
