import Foundation
import SwiftPackageManager
import GitHubClient

struct GithubClientFetcher: VersionFetching {
    private let client = GithubClient()

    func fetchLatestVersion(for dependency: Dependency) async throws -> String? {
        try await client.getLatestRelease(repo: dependency.cloneURL.repoName)?.tagName
    }
}

// TODO: This is specific to GitHub/SCM and it should be removed
private extension CloneUrl {
    struct InvalidCloneUrl: Error {
        let message: String
    }

    var repoName: RepoName {
        get throws {
            let pieces = value.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
            guard pieces.count == 2 else {
                throw InvalidCloneUrl(message: "Expected Clone url's path to only have 2 elements")
            }

            return RepoName(
                owner: String(pieces[0]),
                name: String(pieces[1].replacingOccurrences(of: ".git", with: ""))
            )
        }
    }
}
