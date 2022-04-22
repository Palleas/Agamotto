import Agamotto
import Foundation
import ArgumentParser

@main
struct CheckDependenciesCommand: AsyncParsableCommand {

    @Argument(completion: .directory)
    private var packagePath: String

    @Flag(name: .customLong("verbose"))
    private var isVerbose: Bool = false

    func run() async throws {
        try await checkDependencies(packagePath: packagePath, isVerbose: isVerbose)
    }
}
