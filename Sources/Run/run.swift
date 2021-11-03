import Agamotto

@main
struct Main {
    static func main() async throws {
        let deps = try parsePackage(path: "/Users/palleas/Caretaker/caretaker/caretaker-api")

        await withThrowingTaskGroup(of: DependencyCheckResult.self) { group in
            for dep in deps {
                group.addTask(priority: .medium) {
                    try await checkDependency(dependency: dep)
                }
            }
        }
    }
}
