import Foundation

struct Request<Response: Decodable> {
    let path: String
}
