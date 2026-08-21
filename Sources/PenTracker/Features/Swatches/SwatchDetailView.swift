import SwiftUI
import SwiftData

struct SwatchDetailView: View {
    @Bindable var swatch: Swatch
    @Environment(\.modelContext) private var context

    @State private var showingEdit = false

    var body: some View {
        Form {
            Section("Details") {
                if let ink = swatch.ink {
                    HStack {
                        Text("Ink")
                        Spacer()
                        ColorSwatchView(hex: ink.colorHex)
                        Text("\(ink.brand) \(ink.colorName)")
                    }
                }
                if let paper = swatch.paper {
                    LabeledContent("Paper", value: "\(paper.brand) \(paper.lineName)")
                }
                LabeledContent("Date Tested", value: swatch.dateTested.formatted(date: .abbreviated, time: .omitted))
                HStack {
                    Text("Rating")
                    Spacer()
                    RatingDisplayView(rating: swatch.rating)
                }
            }

            if let notes = swatch.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            if let photo = swatch.photo, let nsImage = NSImage(data: photo) {
                Section("Photo") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 240)
                }
            }

            Section {
                Button("Delete Swatch", role: .destructive) {
                    context.delete(swatch)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Swatch")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            SwatchEditSheet(presetInk: nil, presetPaper: nil, swatch: swatch)
        }
    }
}
