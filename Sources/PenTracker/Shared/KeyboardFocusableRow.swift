import SwiftUI

/// A read-only detail row that participates in keyboard navigation: it is
/// focusable, so Tab/Shift-Tab moves across the fields of a detail screen,
/// and its value is selectable for copy. Visual appearance matches a plain
/// `LabeledContent` row.
struct KeyboardFocusableRow<Value: View>: View {
        let label: String
        @ViewBuilder var value: () -> Value

        var body: some View {
                LabeledContent(label) {
                        value()
                                .textSelection(.enabled)
                                .focusable()
                }
        }
}
