import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var state: DemoState
    @Published var errorMessage: String?
    @Published var demoOutcome: DemoBookingGateway.Outcome = .accepted
    private let repository: DemoRepository

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CareShare", isDirectory: true)
        let testing = ProcessInfo.processInfo.arguments.contains("--uitesting")
        repository = DemoRepository(fileURL: directory.appendingPathComponent(testing ? "ui-test.json" : "demo-plan.json"))
        if ProcessInfo.processInfo.arguments.contains("--reset-demo") {
            state = .seeded()
            do { try repository.save(state) } catch { errorMessage = "The demo could not be saved: \(error.localizedDescription)" }
        } else if FileManager.default.fileExists(atPath: repository.fileURL.path) {
            do { state = try repository.load() }
            catch { state = DemoState(); errorMessage = "Saved data could not be opened. The original file is preserved until you create or reset a plan. \(error.localizedDescription)" }
        } else {
            state = DemoState()
        }
    }

    /// Commit only after persistence succeeds, so a failed save never looks successful.
    @discardableResult
    func change(_ body: (inout DemoState) throws -> Void) -> Bool {
        do {
            var next = state
            try body(&next)
            try repository.save(next)
            state = next
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func reset(withSupporter: Bool = true) {
        if change({ $0 = .seeded(withSupporter: withSupporter) }) { demoOutcome = .accepted }
    }
}
