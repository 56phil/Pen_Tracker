import SwiftUI
import SwiftData

struct SwatchEditSheet: View {
    let presetInk: Ink?
    let presetPaper: Paper?
    var swatch: Swatch? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Ink.brand) private var allInks: [Ink]
    @Query(sort: \Paper.brand) private var allPapers: [Paper]

    @State private var selectedInk: Ink?
    @State private var selectedPaper: Paper?
    @State private var dateTested: Date = .now
    @State private var rating: Int?
    @State private var notes = ""
    @State private var photo: Data?

    var body: some View {
        NavigationStack {
            Form {
                if presetInk == nil {
                    Picker("Ink", selection: $selectedInk) {
                        Text("Choose an ink").tag(Ink?.none)
                        ForEach(allInks) { ink in
                            Text("\(ink.brand) \(ink.colorName)").tag(Ink?.some(ink))
                        }
                    }
                } else if let ink = presetInk {
                    LabeledContent("Ink", value: "\(ink.brand) \(ink.colorName)")
                }

                if presetPaper == nil {
                    Picker("Paper", selection: $selectedPaper) {
                        Text("Choose a paper").tag(Paper?.none)
                        ForEach(allPapers) { paper in
                            Text("\(paper.brand) \(paper.lineName)").tag(Paper?.some(paper))
                        }
                    }
                } else if let paper = presetPaper {
                    LabeledContent("Paper", value: "\(paper.brand) \(paper.lineName)")
                }

                DatePicker("Date Tested", selection: $dateTested, displayedComponents: .date)

                Section("Rating") {
                    RatingView(rating: $rating)
                }

                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }

                Section("Photo") {
                    ImagePickerButton(photo: $photo, label: "Choose Swatch Photo…")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(swatch == nil ? "Swatch Test" : "Edit Swatch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled((presetInk ?? selectedInk) == nil || (presetPaper ?? selectedPaper) == nil)
                }
            }
        }
        .onAppear(perform: loadIfEditing)
        .frame(minWidth: 420, minHeight: 460)
    }

    private func loadIfEditing() {
        guard let swatch else { return }
        selectedInk = swatch.ink
        selectedPaper = swatch.paper
        dateTested = swatch.dateTested
        rating = swatch.rating
        notes = swatch.notes ?? ""
        photo = swatch.photo
    }

    private func save() {
        guard let ink = presetInk ?? selectedInk, let paper = presetPaper ?? selectedPaper else { return }
        if let swatch {
            swatch.ink = ink
            swatch.paper = paper
            swatch.dateTested = dateTested
            swatch.rating = rating
            swatch.notes = notes.isEmpty ? nil : notes
            swatch.photo = photo
        } else {
            let newSwatch = Swatch(ink: ink, paper: paper, dateTested: dateTested,
                                    rating: rating, notes: notes.isEmpty ? nil : notes, photo: photo)
            context.insert(newSwatch)
        }
        dismiss()
    }
}
