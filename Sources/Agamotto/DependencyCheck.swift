import Foundation
import GitHubClient

public enum DependencyErrorType: Error {
    case unsupportedScm
    case scmAPIError(Error)
}
public enum DependencyCheckResult {
    case unknown
    case upToDate
    case outdated(currentVersion: String, latestVersion: String)
    case error(type: DependencyErrorType)

    var isUpToDate: Bool {
        switch self {
        case .upToDate: return true
        default: return false
        }
    }
}

let client = GithubClient()

public func checkDependency(dependency: Dependency) async throws -> DependencyCheckResult {
    guard try dependency.cloneURL.host == "github.com" else {
        return .error(type: .unsupportedScm)
    }

    do {
        guard let latestRelease = try await client.getLatestRelease(repo: dependency.cloneURL.repoName) else {
            return .unknown
        }

        if latestRelease.tagName != dependency.version {
            return .outdated(currentVersion: dependency.version, latestVersion: latestRelease.tagName)
        } else {
            return .upToDate
        }
    } catch let error {
        return .error(type: .scmAPIError(error))
    }
}

public func checkDependencies(packagePath: String) async throws {
    let deps = try parsePackage(path: packagePath)

    guard !deps.isEmpty else {
        print("This project does not have any dependencies.")
        return
    }

    let statuses = try await withThrowingTaskGroup(of: (Dependency, DependencyCheckResult).self, returning: [(Dependency, DependencyCheckResult)].self) { group in
        var statuses = [(Dependency, DependencyCheckResult)]()
        statuses.reserveCapacity(deps.count)

        for dep in deps {
            group.addTask(priority: .medium) {
                try (dep, await checkDependency(dependency: dep))
            }
        }

        return try await group.reduce(into: statuses) { $0.append($1) }
    }

    if statuses.allSatisfy(\.1.isUpToDate) {
        print("All your dependencies are up to date!")
    } else {
        for (dep, status) in statuses {
            switch status {
            case .unknown:
                print("[\(dep.name)] Unable to determine the latest release for this dependency")
            case .upToDate:
                print("[\(dep.name)] Dependency is up to date")
            case .outdated(currentVersion: let currentVersion, latestVersion: let latestVersion):
                print("[\(dep.name)] Dependency should be updated from \(currentVersion) to \(latestVersion)")
            case .error(type: let type):
                print("[\(dep.name)] There was an error checking for that dependency: \(type)")
            }
        }
    }
}
