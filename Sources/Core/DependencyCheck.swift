import Foundation
import GitHubClient

public enum DependencyErrorType: Error, Equatable {
    case unsupportedScm
    case invalidVersionSpecification
    case checkingError
}

struct GithubClientFetcher: VersionFetching {
    private let client = GithubClient()
    
    func fetchLatestVersion(for dependency: Dependency) async throws -> String? {
        try await client.getLatestRelease(repo: dependency.cloneURL.repoName)?.tagName
    }
}

public func checkDependencies(packagePath: String, isVerbose: Bool) async throws {
    
    let checker = DependencyChecker(
        versionFetcherFactory: VersionFetcherFactory(
            fetchers: [:]
        )
    )
//    let deps = try parsePackage(path: packagePath)
//
//    guard !deps.isEmpty else {
//        print("This project does not have any dependencies.")
//        return
//    }
//
//    let statuses = try await withThrowingTaskGroup(of: (Dependency, DependencyCheckResult).self, returning: [(Dependency, DependencyCheckResult)].self) { group in
//        var statuses = [(Dependency, DependencyCheckResult)]()
//        statuses.reserveCapacity(deps.count)
//
//        for dep in deps {
//            group.addTask(priority: .medium) {
//                try (dep, await checkDependency(dependency: dep))
//            }
//        }
//
//        return try await group.reduce(into: statuses) { $0.append($1) }
//    }
//
//    if statuses.allSatisfy(\.1.isUpToDate) {
//        print("All your dependencies are up to date!")
//    } else {
//        for (dep, status) in statuses where !status.isUpToDate || isVerbose {
//            switch status {
//            case .unknown:
//                print("[\(dep.name)] Unable to determine the latest release for this dependency")
//            case .upToDate:
//                print("[\(dep.name)] Dependency is up to date")
//            case .outdated(currentVersion: let currentVersion, latestVersion: let latestVersion):
//                print("[\(dep.name)] Dependency should be updated from \(currentVersion) to \(latestVersion)")
//            case .error(type: let type):
//                print("[\(dep.name)] There was an error checking for that dependency: \(type)")
//            }
//        }
//    }
}
