import SwiftUI
import SwiftData

struct InkingEditSheet: View {
    let inking: Inking

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Pen.brand) private var allPens: [Pen]
    @Query(sort: \Ink.brand) private var allInks: [Ink]

    @State private var selectedPen: Pen?
    @State private var selectedInk: Ink?
    @State private var filledDate: Date = .now
    @State private var emptiedDate: Date?
    @State private var notes = ""
    @State private var rating: ItemRating?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Picker("Pen", selection: $selectedPen) {
                    Text("Choose a pen").tag(Pen?.none)
                    ForEach(allPens) { pen in
                        Text("\(pen.brand) \(pen.model)").tag(Pen?.some(pen))
                    }
                }

                Picker("Ink", selection: $selectedInk) {
                    Text("Choose an ink").tag(Ink?.none)
                    ForEach(allInks) { ink in
                        Text("\(ink.brand) \(ink.colorName)").tag(Ink?.some(ink))
                    }
                }

                DatePicker("Filled Date", selection: $filledDate, in: ...Date.now, displayedComponents: .date)

                Toggle("Currently Inked", isOn: Binding(
                    get: { emptiedDate == nil },
                    set: { isCurrent in
                        emptiedDate = isCurrent ? nil : .now
                    }
                ))

                if let emptiedDate {
                    DatePicker("Emptied Date", selection: Binding(
                        get: { emptiedDate },
                        set: { self.emptiedDate = $0 }
                    ), in: filledDate...Date.now, displayedComponents: .date)
                }

                Section("Rating") {
                    ItemRatingPicker(rating: $rating)
                }

                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Inking")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(selectedPen == nil || selectedInk == nil)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .confirmationDialog("Delete this inking record?", isPresented: $showingDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    context.delete(inking)
                    dismiss()
                }
            }
        }
        .onAppear(perform: load)
        .frame(minWidth: 420, minHeight: 420)
    }

    private func load() {
        selectedPen = inking.pen
        selectedInk = inking.ink
        filledDate = inking.filledDate
        emptiedDate = inking.emptiedDate
        notes = inking.notes ?? ""
        rating = inking.rating
    }

    private func save() {
        guard let pen = selectedPen, let ink = selectedInk else { return }

        if let penToEmpty = inking.pen, penToEmpty !== pen,
           let current = penToEmpty.currentInking, current === inking {
            current.emptiedDate = .now
        }

        inking.pen = pen
        inking.ink = ink
        inking.filledDate = filledDate
        inking.emptiedDate = emptiedDate
        inking.notes = notes.isEmpty ? nil : notes
        inking.rating = rating
        dismiss()
    }
}
