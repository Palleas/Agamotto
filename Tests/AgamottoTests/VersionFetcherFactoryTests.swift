import XCTest
import Core

private struct GithubFetcher: VersionFetching, Equatable {
    func fetchLatestVersion(for dependency: Dependency) -> String? {
        fatalError()
    }
}

final class VersionFetcherFactoryTests: XCTestCase {
    
    let factory = VersionFetcherFactory(fetchers: [
        "github.com": GithubFetcher()
    ])
    
    func testProvidingFetcher_unsupportedHost() {
        XCTAssertThrowsError(try factory.versionFetching(for: "gitlab.com")) { error in
            guard let error = error as? VersionFetcherFactory.Error else {
                return XCTFail("Invalid error of type \(String(describing: type(of: error))) but VersionFetcherFactory.Error was expected")
            }

            XCTAssertEqual(
                error,
                VersionFetcherFactory.Error(
                    host: "gitlab.com",
                    supportedHosts: ["github.com"]
                )
            )
        }
    }
    
    func testProvidingFetcher() throws {
        let fetcher = try factory.versionFetching(for: "github.com")
        XCTAssertTrue(fetcher is GithubFetcher)
    }
}
