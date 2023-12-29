import Foundation
import SwiftPackageManager

public protocol VersionFetching {
    func fetchLatestVersion(for dependency: Dependency) async throws -> String?
}

public struct VersionFetcherFactory {
    
    public struct Error: Swift.Error, Equatable {
        public let host: String
        public let supportedHosts: [String]
        
        public init(host: String, supportedHosts: [String]) {
            self.host = host
            self.supportedHosts = supportedHosts
        }
    }
    
    let fetchers: [String: VersionFetching]
    
    public init(fetchers: [String : VersionFetching]) {
        self.fetchers = fetchers
    }
    
    public func versionFetching(for host: String) throws -> any VersionFetching {
        guard let fetcher = fetchers[host] else {
            throw Error(
                host: host,
                supportedHosts: Array(fetchers.keys)
            )
        }
        
        return fetcher
    }
}
