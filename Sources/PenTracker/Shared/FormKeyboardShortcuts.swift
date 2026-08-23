import SwiftUI

/// Standard keyboard shortcuts for a modal form or sheet: Cmd-S saves,
/// Esc cancels. The form registers itself with the global command center so
/// the menu commands stay enabled only while a form is on screen.
struct FormKeyboardShortcuts: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let save: () -> Void
    let cancel: () -> Void

    func body(content: Content) -> some View {
        content
            .keyboardSaveAction(save)
            .keyboardCancelAction(cancel)
    }
}

extension View {
    /// Attaches Cmd-S (save) and Esc (cancel) to a form or sheet. Both
    /// actions are also reachable through the File menu when a form is
    /// visible.
    func formKeyboardShortcuts(
        save: @escaping () -> Void,
        cancel: @escaping () -> Void
    ) -> some View {
        modifier(FormKeyboardShortcuts(save: save, cancel: cancel))
    }
}
