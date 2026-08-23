import SwiftUI

/// File-menu commands that mirror the toolbar actions so every GUI action is
/// reachable from the keyboard. Commands dispatch to the most recently
/// registered screen (see CommandCenter); they no-op safely when no matching
/// screen is visible. Menu enablement cannot track screen state reactively
/// (Commands are not views), so the items stay enabled and the target
/// registry decides whether anything happens.
struct KeyboardCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Divider()
            Button("Edit…") { CommandCenter.shared.runEdit() }
                .keyboardShortcut("e", modifiers: .command)
            Button("Ink This Pen…") { CommandCenter.shared.runInk() }
                .keyboardShortcut("i", modifiers: .command)
            Button("Swatch on Paper…") { CommandCenter.shared.runSwatch() }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            Button("Back") { CommandCenter.shared.runBack() }
                .keyboardShortcut("[", modifiers: .command)
        }

        CommandGroup(after: .saveItem) {
            Button("Save") { CommandCenter.shared.runSave() }
                .keyboardShortcut("s", modifiers: .command)
            Button("Cancel") { CommandCenter.shared.runCancel() }
                .keyboardShortcut(.cancelAction)
            Button("Delete…") { CommandCenter.shared.runDelete() }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
        }
    }
}
