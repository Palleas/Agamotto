import Core
import Foundation
import ArgumentParser

@main
struct Entrypoint: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "agamotto",
        subcommands: [CheckDependenciesCommand.self],
        defaultSubcommand: CheckDependenciesCommand.self
    )
    
}
