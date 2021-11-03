import Foundation

public struct Dependency: Decodable {
    public let name: String
    public let url: URL
    public let version: String
}

public func parsePackage(path: String) throws -> [Dependency] {
    let magicCommand = """
swift package dump-package --package-path \(path) | jq -Mc "[ .dependencies[].scm[0] | { name: .identity, url: .location, version: .requirement.exact[0] }]"
"""
    let output = Pipe()

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", magicCommand]

    process.standardOutput = output

    try process.run()
    process.waitUntilExit()

    guard let data = try output.fileHandleForReading.readToEnd() else {
        fatalError("No Data")
    }

    return try JSONDecoder().decode([Dependency].self, from: data)
}
