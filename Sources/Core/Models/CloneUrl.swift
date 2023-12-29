import Foundation
import GitHubClient

enum InvalidCloneUrlError: Error {
    case missingHost
    case invalidPath
}

public struct CloneUrl: Decodable {
    public let value: URL
    
    public init(from decoder: Decoder) throws {
        self.value = try decoder.singleValueContainer().decode(URL.self)
        
    }
    
    public init(url: URL) {
        self.value = url
    }
    
    public var host: String {
        get throws {
            guard let host = value.host() else { throw InvalidCloneUrlError.missingHost }
            return host
        }
    }
}

// TODO: This is specific to GitHub/SCM and it should be removed
extension CloneUrl {
    var repoName: RepoName {
        get throws {
            let pieces = value.path.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: true)
            guard pieces.count == 2 else {
                throw InvalidCloneUrlError.invalidPath
            }

            return RepoName(
                owner: String(pieces[0]),
                name: String(pieces[1].replacingOccurrences(of: ".git", with: ""))
            )
        }
    }
}
