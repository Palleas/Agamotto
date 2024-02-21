import Foundation
import SwiftPackageManager
import GitHubClient
import OpenAPIURLSession

struct GithubClientFetcher: VersionFetching {
    private let client = {
        do {
            return try Client(serverURL: .init(validatingOpenAPIServerURL: "https://api.github.com"), transport: URLSessionTransport())
        } catch let error {
            fatalError("Unable to create Github Client?")
        }
    }()
    
    func fetchLatestVersion(for dependency: Dependency) async throws -> String? {
        let repoName = try dependency.cloneURL.repoName
        let response = try await client.repos_sol_get_hyphen_latest_hyphen_release(
            path: .init(
                owner: repoName.owner,
                repo: repoName.name
            )
        )
        
        return try response.ok.body.json.tag_name
    }
}

// TODO: This is specific to GitHub/SCM and it should be removed
private extension CloneUrl {
    struct InvalidCloneUrl: Error {
        let message: String
    }

    var repoName: (owner: String, name: String) {
        get throws {
            let pieces = value.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
            guard pieces.count == 2 else {
                throw InvalidCloneUrl(message: "Expected Clone url's path to only have 2 elements")
            }

            return (
                owner: String(pieces[0]),
                name: String(pieces[1].replacingOccurrences(of: ".git", with: ""))
            )
        }
    }
}
