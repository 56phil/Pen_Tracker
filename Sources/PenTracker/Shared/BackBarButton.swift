import SwiftUI

/// Custom navigation back button that mirrors the system chevron but carries
/// a tooltip and a keyboard equivalent (Cmd-[, registered globally via
/// `keyboardBackAction`). Used in place of the system back button, which
/// cannot show a help hint.
struct BackBarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
        }
        .help("Back (⌘[)")
    }
}
