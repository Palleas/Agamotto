import Foundation

public struct CloneUrl: Decodable, Equatable {
    public let value: URL

    public init(from decoder: Decoder) throws {
        self.value = try decoder.singleValueContainer().decode(URL.self)

    }

    public init(url: URL) {
        self.value = url
    }

    public var host: String? { value.host() }
}
