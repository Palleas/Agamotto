import Foundation

private extension Pipe {
    func readToEnd() throws -> Data? {
        try fileHandleForReading.readToEnd()
    }
}

public struct CommandRunResult {
    let standardOutput: () throws -> Data?
    let standardError: () throws -> Data?
    let terminationStatus: Int
    
    var isSuccess: Bool { terminationStatus == 0 }
    
    public init(standardOutput: @escaping () throws -> Data?, standardError: @escaping () throws -> Data?, terminationStatus: Int) {
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.terminationStatus = terminationStatus
    }
}

public protocol CommandRunning {
    func run(command: String) throws -> CommandRunResult
}

public struct CommandRunner: CommandRunning {
    public init() {}
    
    public func run(command: String) throws -> CommandRunResult {
        let output = Pipe()
        let standardError = Pipe()
        
        let process = Process()
        // TODO: double check path to bash but we should probably use /bin/env or something
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        process.standardError = standardError
        process.standardOutput = output
        
        try process.run()
        process.waitUntilExit()
        
        return CommandRunResult(
            standardOutput: { try output.readToEnd() },
            standardError: { try standardError.readToEnd() },
            terminationStatus: Int(process.terminationStatus)
        )
    }
}
