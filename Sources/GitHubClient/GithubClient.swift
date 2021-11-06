import Foundation

public struct GithubClient {

    enum GitHubError: Error {
        case invalidResponse
    }

    static let githubJsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let baseEndpoint: URL = URL(string: "https://api.github.com")!

    public init() {}

    public func getLatestRelease(repo: RepoName) async throws -> GithubRelease {
        let (release, _) = try await send(request: repo.latestRelease)
        return release
    }

    func send<T: Decodable>(request: Request<T>) async throws -> (T, HTTPURLResponse) {
        let urlRequest = URLRequest(url: baseEndpoint.appendingPathComponent(request.path))
        let (data, response) = try await URLSession.shared.data(for: urlRequest, delegate: nil)

        let httpResponse = response as! HTTPURLResponse
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 else {
            throw GitHubError.invalidResponse
        }

        let payload = try GithubClient.githubJsonDecoder.decode(T.self, from: data)
        return (payload, httpResponse)
    }
}
