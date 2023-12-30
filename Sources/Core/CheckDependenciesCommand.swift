import Foundation
import GitHubClient
import SwiftPackageManager
import ArgumentParser

public enum DependencyErrorType: Error, Equatable {
    case unsupportedScm
    case invalidVersionSpecification
    case checkingError
}

private func defaultCacheDirectory() -> URL {
    #if os(Linux)
    FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Caches", isDirectory: true)
    #else
    URL.cachesDirectory
    #endif
}

public struct CheckDependenciesCommand: AsyncParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(commandName: "check")
    
    @Argument
    private var packagePath: String
    
    @Flag(name: .customLong("verbose"))
    private var isVerbose: Bool = false
    
    public init() {}
    
    public func run() async throws {
        let checker = DependencyChecker(
            versionFetcherFactory: VersionFetcherFactory(
                fetchers: ["github.com": GithubClientFetcher()]
            )
        )

        let parser = ManifestParser(runner: CommandRunner(), cachesDirectory: defaultCacheDirectory())
        let deps = try parser.parsePackage(path: packagePath)

        guard !deps.isEmpty else {
            print("This project does not have any dependencies.")
            return
        }

        typealias CheckResult = (Dependency, DependencyChecker.DependencyCheckResult)

        let statuses = try await withThrowingTaskGroup(of: CheckResult.self, returning: [CheckResult].self) { group in
            var statuses = [(Dependency, DependencyChecker.DependencyCheckResult)]()
            statuses.reserveCapacity(deps.count)

            for dep in deps {
                group.addTask(priority: .medium) {
                    try (dep, await checker.check(dependency: dep))
                }
            }

            return try await group.reduce(into: statuses) { $0.append($1) }
        }

        let summaryGenerator = SummaryGenerator()
        if statuses.allSatisfy(\.1.isUpToDate) {
            print("All your dependencies are up to date!")
        } else {
            let includedStatuses = statuses.filter { _, result in !result.isUpToDate || isVerbose }
            
            let maxLength = includedStatuses.map(\.0.name.count).max() ?? 0
            
            for (dep, result) in includedStatuses {
                let summary = summaryGenerator.summary(dependency: dep, result: result)
                print("[\(dep.name)\(String(repeating: ".", count: max(maxLength - dep.name.count, 0)))] \(summary)")
            }
        }
    }
}
