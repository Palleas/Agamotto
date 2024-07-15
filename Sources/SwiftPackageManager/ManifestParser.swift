import Foundation

public struct RuntimeError: LocalizedError {
    public let message: String
    
    public var errorDescription: String? { message }
}

public struct ManifestParser {

    let runner: CommandRunning
    let cachesDirectory: URL
    let isVerbose: Bool

    public init(runner: CommandRunning, cachesDirectory: URL, isVerbose: Bool) {
        self.runner = runner
        self.cachesDirectory = cachesDirectory
        self.isVerbose = isVerbose
    }

    public func parsePackage(path: String) throws -> [Dependency] {
        let swiftPackageDumpCommand = "swift package dump-package --package-path \(path)"

        let dumpPackageCommandResult = try runner.run(command: swiftPackageDumpCommand)

        guard dumpPackageCommandResult.isSuccess else {
            try createRuntimeError(description: "unable to parse the Package manifest", result: dumpPackageCommandResult)
        }

        guard let data = try dumpPackageCommandResult.standardOutput() else {
            try createRuntimeError(description: "unable to parse the Package manifest", result: dumpPackageCommandResult)
        }

        do {
            let response = try JSONDecoder().decode(PackageDumpResponse.self, from: data)
            return try response.dependencies.map { dependency in
                guard let sourceControl = dependency.sourceControl.first else { throw RuntimeError(message: "Missing source control entry") }
                
                guard let urlString = sourceControl.location.remote.first?["urlString"].flatMap(URL.init(string:)) else { throw RuntimeError(message: "Missing or invalid remote url") }
                
                return Dependency(
                    name: sourceControl.identity,
                    cloneURL: CloneUrl(url: urlString),
                    version: sourceControl.requirement.exact?.first
                )
            }
        } catch is DecodingError {
            try createRuntimeError(
                description: "Unable to parse the Package manifest. This can happen when the response format of the `swift package dump-package` command has changed",
                result: dumpPackageCommandResult
            )
        }
    }
}

private func createRuntimeError(description: String, result: CommandRunResult) throws -> Never {
    let output = try result.standardOutput().map { String(decoding: $0, as: UTF8.self) } ?? "No output"
    let error = try result.standardError().map { String(decoding: $0, as: UTF8.self) } ?? "No error output"
    
    throw RuntimeError(message: """
An error occured while running agamotto: \(description)

Standard output: \(output)
Standard error: \(error)
""")
}
