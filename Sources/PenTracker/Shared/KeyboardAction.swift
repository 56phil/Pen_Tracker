import SwiftUI

/// Registers the view as a keyboard target while it is on screen, so the
/// matching global menu command (e.g. Cmd-E) routes to it. Multiple
/// windows each register their own target; commands hit the most recently
/// registered (topmost) one.
private struct KeyboardTarget: ViewModifier {
    @State private var token: UUID?
    let register: (@escaping () -> Void) -> UUID
    let unregister: (UUID) -> Void
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                if token == nil { token = register(action) }
            }
            .onDisappear {
                if let token {
                    unregister(token)
                    self.token = nil
                }
            }
    }
}

extension View {
    /// Makes the global Edit command (Cmd-E) target this view.
    func keyboardEditAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerEdit,
                unregister: CommandCenter.shared.unregisterEdit,
                action: action))
    }

    /// Makes the global Ink command (Cmd-I) target this view.
    func keyboardInkAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerInk,
                unregister: CommandCenter.shared.unregisterInk,
                action: action))
    }

    /// Makes the global Swatch command (Cmd-Shift-W) target this view.
    func keyboardSwatchAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerSwatch,
                unregister: CommandCenter.shared.unregisterSwatch,
                action: action))
    }

    /// Makes the global Save command (Cmd-S) target this view.
    func keyboardSaveAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerSave,
                unregister: CommandCenter.shared.unregisterSave,
                action: action))
    }

    /// Makes the global Delete command (Cmd-Shift-Delete) target this view.
    func keyboardDeleteAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerDelete,
                unregister: CommandCenter.shared.unregisterDelete,
                action: action))
    }
    /// Makes the global Back command (Cmd-[) target this view.
    func keyboardBackAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerBack,
                unregister: CommandCenter.shared.unregisterBack,
                action: action))
    }

    /// Makes the global Cancel command (Esc) target this view.
    func keyboardCancelAction(_ action: @escaping () -> Void) -> some View {
        modifier(
            KeyboardTarget(
                register: CommandCenter.shared.registerCancel,
                unregister: CommandCenter.shared.unregisterCancel,
                action: action))
    }
}
