import SwiftUI
import SwiftData

struct PaperDetailView: View {
    @Bindable var paper: Paper
    @Environment(\.modelContext) private var context

    @State private var showingEdit = false
    @State private var showingSwatchSheet = false

    private var sortedSwatches: [Swatch] {
        paper.swatches.sorted { $0.dateTested > $1.dateTested }
    }

    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Brand", value: paper.brand)
                LabeledContent("Line", value: paper.lineName)
                LabeledContent("Format", value: paper.format)
                if let gsm = paper.weightGSM {
                    LabeledContent("Weight", value: "\(gsm) gsm")
                }
                if let finish = paper.colorOrFinish, !finish.isEmpty {
                    LabeledContent("Color / Finish", value: finish)
                }
                LabeledContent("Quantity", value: "\(paper.quantity)")
                LabeledContent("Status") { StatusBadge(status: paper.status) }
            }

            Section("Swatch Tests") {
                Button("Swatch an Ink on This…") { showingSwatchSheet = true }
                ForEach(sortedSwatches) { swatch in
                    if let ink = swatch.ink {
                        HStack {
                            ColorSwatchView(hex: ink.colorHex)
                            Text("\(ink.brand) \(ink.colorName)")
                            Spacer()
                            RatingDisplayView(rating: swatch.rating)
                        }
                    }
                }
            }

            if let vendor = paper.vendor, !vendor.isEmpty {
                Section("Purchase") {
                    LabeledContent("Vendor", value: vendor)
                    if let price = paper.price {
                        LabeledContent("Price", value: price.formatted(.currency(code: "USD")))
                    }
                    if let date = paper.purchaseDate {
                        LabeledContent("Date", value: date.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let url = paper.purchaseURL {
                        Link("Purchase Link", destination: url)
                    }
                }
            }

            if !paper.notes.isEmpty {
                Section("Notes") {
                    Text(paper.notes)
                }
            }

            if let photo = paper.photo, let nsImage = NSImage(data: photo) {
                Section("Photo") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("\(paper.brand) \(paper.lineName)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            PaperEditView(paper: paper)
        }
        .sheet(isPresented: $showingSwatchSheet) {
            SwatchEditSheet(presetInk: nil, presetPaper: paper)
        }
    }
}
