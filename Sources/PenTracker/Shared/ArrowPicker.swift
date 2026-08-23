import SwiftUI

/// A `Picker` with arrow-key navigation: when the pop-up button has keyboard
/// focus, Up/Down cycle through `options` (wrapping around), so a dropdown
/// choice can be changed without the mouse. Tab still moves focus between
/// fields.
struct ArrowPicker<SelectionValue: Hashable, Content: View>: View {
    @Binding var selection: SelectionValue
    let options: [SelectionValue]
    let title: LocalizedStringKey
    @ViewBuilder var content: () -> Content

    var body: some View {
        Picker(title, selection: $selection, content: content)
            .focusable()
            .onKeyPress(.upArrow) {
                step(-1)
                return .handled
            }
            .onKeyPress(.downArrow) {
                step(1)
                return .handled
            }
    }

    private func step(_ direction: Int) {
        guard let current = options.firstIndex(of: selection) else { return }
        let next = (current + direction + options.count) % options.count
        selection = options[next]
    }
}

extension ArrowPicker {
    init(
        _ title: LocalizedStringKey,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.content = content
    }
}
