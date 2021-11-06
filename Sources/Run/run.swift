import Agamotto

@main
struct Main {
    static func main() async throws {
        try await checkDependencies(packagePath: "/Users/palleas/Caretaker/caretaker/caretaker-api")
    }
}
