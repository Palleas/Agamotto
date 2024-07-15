import Foundation

public struct PackageDumpResponse: Decodable {
    public struct SourceControlLocation: Decodable {
        let remote: [[String: String]]
    }
    
    public struct Requirement: Decodable {
        let exact: [String]?
    }
    
    public struct SourceControl: Decodable {
        let identity: String
        let location: SourceControlLocation
        let requirement: Requirement
    }
    
    public struct Dependency: Decodable {
        let sourceControl: [SourceControl]
    }
    
    public let dependencies: [Dependency]
    
}
