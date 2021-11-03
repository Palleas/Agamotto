import Foundation

public struct GithubRelease: Decodable {
    public let tagName: String
}

public struct RepoName {
    public let owner: String
    public let name: String

    public init(owner: String, name: String) {
        self.owner = owner
        self.name = name
    }
}
