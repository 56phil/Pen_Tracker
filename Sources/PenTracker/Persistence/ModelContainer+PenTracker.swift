import Foundation
import SwiftData

enum PenTrackerContainer {
    static func make() -> ModelContainer {
        let schema = Schema([Pen.self, Ink.self, Paper.self, Inking.self, Swatch.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false,
                                         cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
