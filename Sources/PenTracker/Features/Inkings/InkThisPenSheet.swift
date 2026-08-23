import SwiftData
import SwiftUI

struct InkThisPenSheet: View {
    let presetPen: Pen?
    let presetInk: Ink?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Pen.brand) private var allPens: [Pen]
    @Query(sort: \Ink.brand) private var allInks: [Ink]

    @State private var selectedPen: Pen?
    @State private var selectedInk: Ink?
    @State private var filledDate: Date = .now
    @State private var notes = ""
    @State private var rating: ItemRating?

    private var canSave: Bool {
        (presetPen ?? selectedPen) != nil && (presetInk ?? selectedInk) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                if presetPen == nil {
                    ArrowPicker(
                        "Pen", selection: $selectedPen,
                        options: [nil] + allPens.map { Pen?.some($0) }
                    ) {
                        Text("Choose a pen").tag(Pen?.none)
                        ForEach(allPens) { pen in
                            Text("\(pen.brand) \(pen.model)").tag(Pen?.some(pen))
                        }
                    }
                } else if let pen = presetPen {
                    LabeledContent("Pen", value: "\(pen.brand) \(pen.model)")
                }

                if presetInk == nil {
                    ArrowPicker(
                        "Ink", selection: $selectedInk,
                        options: [nil] + allInks.map { Ink?.some($0) }
                    ) {
                        Text("Choose an ink").tag(Ink?.none)
                        ForEach(allInks) { ink in
                            Text("\(ink.brand) \(ink.colorName)").tag(Ink?.some(ink))
                        }
                    }
                } else if let ink = presetInk {
                    LabeledContent("Ink", value: "\(ink.brand) \(ink.colorName)")
                }

                DatePicker(
                    "Filled Date", selection: $filledDate, in: ...Date.now,
                    displayedComponents: .date)

                Section("Rating") {
                    ItemRatingPicker(rating: $rating)
                }

                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Ink This Pen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .help("Cancel (Esc)")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                        .help("Save (⌘S)")
                }
            }
        }
        .frame(minWidth: 400, minHeight: 340)
        .formKeyboardShortcuts(
            save: { if canSave { save() } },
            cancel: { dismiss() })
    }

    private func save() {
        guard let pen = presetPen ?? selectedPen, let ink = presetInk ?? selectedInk else { return }

        if let current = pen.currentInking {
            current.emptiedDate = .now
        }

        let inking = Inking(
            pen: pen, ink: ink, filledDate: filledDate,
            notes: notes.isEmpty ? nil : notes, rating: rating)
        context.insert(inking)
        // Setting the inverse (Inking.pen) above doesn't retroactively
        // notify observers of Pen.inkings, so views reading
        // pen.currentInking (e.g. PenDetailView) don't refresh unless we
        // touch the array on the "one" side directly.
        pen.inkings.append(inking)
        dismiss()
    }
}
