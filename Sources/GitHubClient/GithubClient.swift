import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct GithubClient {

    enum GitHubError: Error {
        case invalidResponse
        case httpError(response: HTTPURLResponse)
    }

    static let githubJsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let baseEndpoint: URL = URL(string: "https://api.github.com")!

    public init() {}

    public func getLatestRelease(repo: RepoName) async throws -> GithubRelease? {
        do {
            let (release, _) = try await send(request: repo.latestRelease)
            return release
        } catch let error as GitHubError {
            switch error {
            case .httpError(response: let response) where response.statusCode == 404:
                return nil
            default:
                throw error
            }
        }
    }

    func send<T: Decodable>(request: Request<T>) async throws -> (T, HTTPURLResponse) {
        let urlRequest = URLRequest(url: baseEndpoint.appendingPathComponent(request.path))

        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                do {
                    if let error = error {
                        throw error
                    }
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        throw GitHubError.invalidResponse
                    }

                    guard response.statusCode >= 200 && response.statusCode < 400 else {
                        throw GitHubError.httpError(response: response)
                    }

                    let payload = try GithubClient.githubJsonDecoder.decode(T.self, from: data)

                    continuation.resume(returning: (payload, response))
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }.resume()
        }
    }
}
