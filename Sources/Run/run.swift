import Agamotto
import Foundation

@main
struct Main {
    static func main() async throws {
        guard let path = ProcessInfo.processInfo.arguments.dropFirst().first else {
            print("Missing path to folder containing Package.swift")
            exit(1)
        }

        try await checkDependencies(packagePath: path)
    }
}
