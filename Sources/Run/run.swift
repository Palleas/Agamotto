import Agamotto
import Foundation
import ArgumentParser

@main
struct CheckDependenciesCommand: ParsableCommand {

    @Argument(completion: .directory)
    private var packagePath: String

    func run() async throws {
        print("Package: \(packagePath)")
        try await checkDependencies(packagePath: packagePath)
    }
//    static func main() async throws {
//        guard let path = ProcessInfo.processInfo.arguments.dropFirst().first else {
//            print("Missing path to folder containing Package.swift")
////            exit(1)
//            return
//        }
//
//        try await checkDependencies(packagePath: path)
//    }
}
