import Foundation
import SwiftData

enum PenTrackerContainer {
    static func make() -> ModelContainer {
        let schema = Schema([Pen.self, Ink.self, Paper.self, Inking.self, Swatch.self])
        let config = ModelConfiguration(schema: schema, url: storeURL(), cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// A store URL scoped to this app specifically. Without this, SwiftData
    /// falls back to a generic, unnamespaced `default.store` shared by any
    /// unsandboxed app on the Mac that also doesn't specify a URL — another
    /// such app can silently overwrite this app's entire database.
    private static func storeURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = appSupport.appending(path: "PenTracker", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appending(path: "PenTracker.store")
    }
}
