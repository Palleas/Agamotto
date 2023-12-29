import Foundation
import SwiftPackageManager

struct SummaryGenerator {
    
    func summary(dependency: Dependency, result: DependencyChecker.DependencyCheckResult) -> String {
        return switch result {
        case .unknown:
            "Unable to determine if this dependency is up to date. This can happen if the dependency uses GitHub and has no published releases, for example"
        case .upToDate:
            "Up to date."
        case .outdated(let currentVersion, let latestVersion):
            "Should be updated from \(currentVersion) to \(latestVersion)"
        case .error(.unsupportedScm):
            "This dependency is hosted on an SCM that is not currently supported"
        case .error(.invalidVersionSpecification):
            "Unable to determine if this dependency is up to date. It should be using a specific version with `.package(url: ..., exact: x.y.z)`."
        case .error(.checkingError):
            "There was an error while fetching if a more recent version is available. This can happen if the service is down."
        }
    }
    
}
