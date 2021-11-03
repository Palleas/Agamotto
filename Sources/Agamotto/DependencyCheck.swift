import Foundation
import GitHubClient

public enum DependencyCheckResult {
    case upToDate
    case outdated(currentVersion: String, latestVersion: String)
    case error(message: String)
}

let client = GithubClient()

public func checkDependency(dependency: Dependency) async throws -> DependencyCheckResult {
    guard dependency.url.host == "github.com" else {
        return .error(message: "Only GitHub.com is supported")
    }

    let pieces = dependency.url.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
    let owner = String(pieces[0])
    let name = String(pieces[1]).replacingOccurrences(of: ".git", with: "")

    let latestRelease = try await client.getLatestRelease(repo: RepoName(owner: owner, name: name))

    if latestRelease.tagName != dependency.version {
        return .outdated(currentVersion: dependency.version, latestVersion: latestRelease.tagName)
    } else {
        return .upToDate
    }
}
