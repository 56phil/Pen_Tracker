import SwiftUI

extension View {
    /// Adds a destructive toolbar "Delete" button that confirms, then runs
    /// `onDelete` and pops back to the previous screen. The confirmation
    /// dialog is also reachable through the global Delete command
    /// (Cmd-Shift-Delete) while the view is visible.
    func deleteToolbarButton(itemDescription: String, onDelete: @escaping () -> Void) -> some View {
        modifier(DeleteToolbarButtonModifier(itemDescription: itemDescription, onDelete: onDelete))
    }
}

private struct DeleteToolbarButtonModifier: ViewModifier {
    let itemDescription: String
    let onDelete: () -> Void

    @State private var showingConfirmation = false
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", role: .destructive) {
                        showingConfirmation = true
                    }
                    .help("Delete (⌘⇧⌫)")
                }
            }
            .keyboardDeleteAction { showingConfirmation = true }
            .confirmationDialog(
                "Delete \(itemDescription)?", isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            }
    }
}
