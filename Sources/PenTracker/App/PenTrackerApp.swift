import SwiftUI

@main
struct PenTrackerApp: App {
    let container = PenTrackerContainer.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .commands {
            KeyboardCommands()
        }
    }
}
