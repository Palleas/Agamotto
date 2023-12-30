import Foundation

public struct Dependency: Decodable, Equatable {
    public let name: String
    public let cloneURL: CloneUrl
    public let version: String?

    public init(name: String, cloneURL: CloneUrl, version: String?) {
        self.name = name
        self.cloneURL = cloneURL
        self.version = version
    }
}
