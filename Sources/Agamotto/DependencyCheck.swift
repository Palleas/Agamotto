import Foundation
import GitHubClient

public enum DependencyErrorType: Error {
    case unsupportedScm
}
public enum DependencyCheckResult {
    case upToDate
    case outdated(currentVersion: String, latestVersion: String)
    case error(type: DependencyErrorType)
}

let client = GithubClient()

public func checkDependency(dependency: Dependency) async throws -> DependencyCheckResult {
    guard try dependency.cloneURL.host == "github.com" else {
        return .error(type: .unsupportedScm)
    }

    let latestRelease = try await client.getLatestRelease(repo: dependency.cloneURL.repoName)

    if latestRelease.tagName != dependency.version {
        return .outdated(currentVersion: dependency.version, latestVersion: latestRelease.tagName)
    } else {
        return .upToDate
    }
}

public func checkDependencies(packagePath: String) async throws {
    let deps = try parsePackage(path: packagePath)

    await withThrowingTaskGroup(of: DependencyCheckResult.self) { group in
        for dep in deps {
            group.addTask(priority: .medium) {
                try await checkDependency(dependency: dep)
            }
        }
    }

}
