import XCTest
import Core

private struct StaticGithubFetcher: VersionFetching {
    func fetchLatestVersion(for dependency: Dependency) async throws -> String? {
        switch dependency.cloneURL.value.absoluteString {
        case "https://github.com/vapor/vapor.git":
            return "1.1.2"
        default:
            return nil
        }
        
    }
}

final class DependencyCheckerTests: XCTestCase {
    let checker = DependencyChecker(
        versionFetcherFactory: VersionFetcherFactory(
            fetchers: ["github.com": StaticGithubFetcher()]
        )
    )
    
    func testDependency_noVersion() async throws {
        let result = try await checker.check(dependency: .packageWithNoVersion)
        XCTAssertEqual(result, .error(type: .invalidVersionSpecification))
    }
    
    func testDependency_unsupportedScm() async throws {
        let result = try await checker.check(dependency: .gitlabDependency)
        XCTAssertEqual(result, .error(type: .unsupportedScm))
    }
    
    func testDependency_outdated() async throws {
        let result = try await checker.check(dependency: .outOfDateVapor)
        XCTAssertEqual(result, .outdated(currentVersion: "1.1.1", latestVersion: "1.1.2"))
    }
    
    func testDependency_upToDate() async throws {
        let result = try await checker.check(dependency: .upToDateVapor)
        XCTAssertEqual(result, .upToDate)
    }
    
    func testDependency_noLatestVersion() async throws {
        let result = try await checker.check(dependency: .packageWithNoReleases)
        XCTAssertEqual(result, .unknown)
    }

}

private extension Dependency {
    static let upToDateVapor = Dependency(
        name: "vapor",
        cloneURL: CloneUrl(url: URL(string: "https://github.com/vapor/vapor.git")!),
        version: "1.1.2"
    )

    static let outOfDateVapor = Dependency(
        name: "vapor",
        cloneURL: CloneUrl(url: URL(string: "https://github.com/vapor/vapor.git")!),
        version: "1.1.1"
    )

    static let gitlabDependency = Dependency(
        name: "my-package",
        cloneURL: CloneUrl(url: URL(string: "https://gitlab.com/palleas/whatever.git")!),
        version: "1.1.1"
    )
    
    static let packageWithNoVersion = Dependency(
        name: "my-package",
        cloneURL: CloneUrl(url: URL(string: "https://github.com/palleas/whatever.git")!),
        version: nil
    )
    
    static let packageWithNoReleases = Dependency(
        name: "my-package",
        cloneURL: CloneUrl(url: URL(string: "https://github.com/palleas/whatever.git")!),
        version: "5.4.3"
    )

}
