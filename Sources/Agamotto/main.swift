import Foundation

struct Dependency: Decodable {
    let name: String
    let url: String
    let version: String
}

func parsePackage(path: String) throws -> [Dependency] {
    let magicCommand = """
swift package dump-package --package-path \(path) | jq -Mc "[ .dependencies[].scm[0] | {name: .identity, url: .location, version: .requirement.exact[0]] }"
"""
    let output = Pipe()

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", magicCommand]

    process.standardOutput = output

    try process.run()
    process.waitUntilExit()

    guard let data = try output.fileHandleForReading.readToEnd() else {
        fatalError("No Data")
    }

    return try JSONDecoder().decode([Dependency].self, from: data)
}

enum DependencyCheckResult {
    case ok
    case error(message: String)
}

struct SomeError: Error {
    let message: String
}

let githubJsonDecoder = JSONDecoder()
githubJsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

struct GithubRelease: Decodable {
    let tagName: String
}

func getLatestRelease(owner: String, repoName: String) async throws -> GithubRelease {
    let request = URLRequest(url: URL(string: "https://api.github.com/repos/\(owner)/\(repoName)/releases/latest")!)

    return try await withCheckedThrowingContinuation { continuation in
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                continuation.resume(throwing: error)
            }

            do {
                guard let response = response as? HTTPURLResponse, let data = data, response.statusCode == 200 else {
                    throw SomeError(message: "Invalid Response")
                }

                continuation.resume(returning: try githubJsonDecoder.decode(GithubRelease.self, from: data))
            } catch let error {
                continuation.resume(throwing: error)
            }
        }
    }
}

func updateIfNeeded(dependency: Dependency) async throws -> DependencyCheckResult {
    guard let url = URL(string: dependency.url) else {
        return .error(message: "Invalid dependency url")
    }

    guard let host = URL(string: dependency.url)?.host, host == "github.com" else {
        return .error(message: "Only GitHub.com is supported")
    }

    let pieces = url.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
    let owner = String(pieces[0])
    let name = String(pieces[1]).replacingOccurrences(of: ".git", with: "")

    let latestRelease = try await getLatestRelease(owner: owner, repoName: name)
    print("Current dependency is \(dependency.name) version \(dependency.version)")
    print("Latest release is \(latestRelease.tagName)")
    return .ok
}

func run() throws {
    Task {
        let deps = try parsePackage(path: "/Users/palleas/Caretaker/caretaker/caretaker-api")

        await withThrowingTaskGroup(of: DependencyCheckResult.self) { group in
            for dep in deps {
                group.addTask {
                    return try await updateIfNeeded(dependency: dep)
                }
            }
        }
    }
}

try run()
