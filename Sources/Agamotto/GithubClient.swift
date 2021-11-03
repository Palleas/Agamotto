import Foundation

enum DependencyCheckResult {
    case ok
    case error(message: String)
}

struct SomeError: Error {
    let message: String
}

func updateIfNeeded(dependency: Dependency) async throws -> DependencyCheckResult {
    let client = GithubClient()
    guard let url = URL(string: dependency.url) else {
        return .error(message: "Invalid dependency url")
    }

    guard let host = URL(string: dependency.url)?.host, host == "github.com" else {
        return .error(message: "Only GitHub.com is supported")
    }

    let pieces = url.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
    let owner = String(pieces[0])
    let name = String(pieces[1]).replacingOccurrences(of: ".git", with: "")

    let latestRelease = try await client.getLatestRelease(owner: owner, repoName: name)
    print("Current dependency is \(dependency.name) version \(dependency.version)")
    print("Latest release is \(latestRelease.tagName)")
    return .ok
}

struct GithubRelease: Decodable {
    let tagName: String
}

struct GithubClient {

    static let githubJsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

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

                    continuation.resume(returning: try GithubClient.githubJsonDecoder.decode(GithubRelease.self, from: data))
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
