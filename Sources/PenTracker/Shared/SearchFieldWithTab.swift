import AppKit
import SwiftUI

/// Toolbar search field that on Tab selects the first filtered collection
/// row and moves keyboard focus into the list, instead of leaving focus in
/// the search box. Visually matches the system `.searchable` field (same
/// NSSearchField control, magnifier and clear button included).
struct SearchFieldWithTab: NSViewRepresentable {
 @Binding var text: String
 let prompt: String
 let onTab: () -> Void

 func makeCoordinator() -> Coordinator { Coordinator(self) }

 func makeNSView(context: Context) -> NSSearchField {
  let field = NSSearchField()
  field.placeholderString = prompt
  field.delegate = context.coordinator
  return field
 }

 func updateNSView(_ nsView: NSSearchField, context: Context) {
  if nsView.stringValue != text {
   nsView.stringValue = text
  }
 }

 final class Coordinator: NSObject, NSSearchFieldDelegate {
  var parent: SearchFieldWithTab

  init(_ parent: SearchFieldWithTab) {
   self.parent = parent
  }

  func controlTextDidChange(_ obj: Notification) {
   if let field = obj.object as? NSSearchField {
    parent.text = field.stringValue
   }
  }

  /// Intercepts Tab while the field is being edited. The field editor
  /// (an NSTextView) owns key events during editing, so this delegate
  /// hook is the only reliable place to catch Tab. Selecting the first
  /// row and focusing the list turns Tab into "jump to first row".
  func control(
   _ control: NSControl, textView: NSTextView,
   doCommandBy commandSelector: Selector
  ) -> Bool {
   if commandSelector == #selector(NSResponder.insertTab(_:)) {
    parent.onTab()
    return true
   }
   return false
  }
 }
}
