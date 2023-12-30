import Core
import Foundation
import ArgumentParser

@main
struct Entrypoint: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "agamotto",
        version: "0.1.0",
        subcommands: [CheckDependenciesCommand.self],
        defaultSubcommand: CheckDependenciesCommand.self
    )
    
}
