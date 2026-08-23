import SwiftData
import SwiftUI

struct SwatchDetailView: View {
    @Bindable var swatch: Swatch
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false

    var body: some View {
        Form {
            Section("Details") {
                if let ink = swatch.ink {
                    KeyboardFocusableRow(label: "Ink") {
                        HStack {
                            ColorSwatchView(hex: ink.colorHex)
                            Text("\(ink.brand) \(ink.colorName)")
                        }
                    }
                }
                if let paper = swatch.paper {
                    KeyboardFocusableRow(label: "Paper") {
                        Text("\(paper.brand) \(paper.lineName)")
                    }
                }
                KeyboardFocusableRow(label: "Date Tested") {
                    Text(swatch.dateTested.abbreviated)
                }
                KeyboardFocusableRow(label: "Rating") { RatingBadgeView(rating: swatch.rating) }
            }

            if let notes = swatch.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            PhotoSection(photo: swatch.photo, maxHeight: 240)
        }
        .formStyle(.grouped)
        .navigationTitle("Swatch")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
                    .help("Edit (⌘E)")
            }
            ToolbarItem(placement: .navigation) {
                BackBarButton { dismiss() }
            }
        }
        .keyboardEditAction { showingEdit = true }
        .keyboardBackAction { dismiss() }
        .sheet(isPresented: $showingEdit) {
            SwatchEditSheet(presetInk: nil, presetPaper: nil, swatch: swatch)
        }
        .deleteToolbarButton(itemDescription: "this swatch") {
            context.delete(swatch)
        }
    }
}
