import Foundation

public struct DependencyChecker {
    
    public enum DependencyCheckResult: Equatable {
        case unknown
        case upToDate
        case outdated(currentVersion: String, latestVersion: String)
        case error(type: DependencyErrorType)

        // TODO: Use case path?
        var isUpToDate: Bool {
            switch self {
            case .upToDate: return true
            default: return false
            }
        }
    }
    
    private let versionFetcherFactory: VersionFetcherFactory

    public init(versionFetcherFactory: VersionFetcherFactory) {
        self.versionFetcherFactory = versionFetcherFactory
    }
    
    public func check(dependency: Dependency) async throws -> DependencyCheckResult {
        guard let currentVersion = dependency.version else {
            return .error(type: .invalidVersionSpecification)
        }
        
        guard try dependency.cloneURL.host == "github.com" else {
            return .error(type: .unsupportedScm)
        }

        do {
            let fetcher = try versionFetcherFactory.versionFetching(for: dependency.cloneURL.host)
            guard let latestVersion = try await fetcher.fetchLatestVersion(for: dependency) else {
                return .unknown
            }
            
            // TODO: Compare version using semver when possible
            if latestVersion != currentVersion {
                return .outdated(currentVersion: currentVersion, latestVersion: latestVersion)
            }
            
            return .upToDate
        } catch is VersionFetcherFactory.Error {
            return .error(type: .unsupportedScm)
        } catch {
            // TODO: Handle error better
            return .error(type: .checkingError) // Generic error
        }
    }
}
