import SwiftUI
import SwiftData
import Foundation

struct InkDetailView: View {
    @Bindable var ink: Ink
    @Environment(\.modelContext) private var context

    @State private var showingEdit = false
    @State private var showingInkSheet = false
    @State private var showingSwatchSheet = false

    private var sortedInkings: [Inking] {
        ink.inkings.sorted { $0.filledDate > $1.filledDate }
    }

    private var sortedSwatches: [Swatch] {
        ink.swatches.sorted { $0.dateTested > $1.dateTested }
    }

    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Brand", value: ink.brand)
                LabeledContent("Line", value: ink.lineName)
                LabeledContent("Color", value: ink.colorName)
                HStack {
                    Text("Swatch")
                    Spacer()
                    ColorSwatchView(hex: ink.colorHex, size: 20)
                }
                LabeledContent("Package", value: ink.packageType.label)
                if let volume = ink.volumeML {
                    LabeledContent("Volume", value: "\(Int(volume)) mL")
                }
                LabeledContent("Quantity Owned", value: "\(ink.quantity)")
                LabeledContent("Status") { StatusBadge(status: ink.status) }
            }

            Section("Used In") {
                Button("Ink a Pen With This…") { showingInkSheet = true }
                ForEach(sortedInkings) { inking in
                    if let pen = inking.pen {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(pen.brand) \(pen.model)")
                                if let notes = inking.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if inking.isCurrent {
                                Text("Current").font(.caption).foregroundStyle(.green)
                            } else {
                                Text(inking.filledDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section("Swatch Tests") {
                Button("Swatch on Paper…") { showingSwatchSheet = true }
                ForEach(sortedSwatches) { swatch in
                    if let paper = swatch.paper {
                        HStack {
                            Text("\(paper.brand) \(paper.lineName)")
                            Spacer()
                            RatingDisplayView(rating: swatch.rating)
                        }
                    }
                }
            }

            if let vendor = ink.vendor, !vendor.isEmpty {
                Section("Purchase") {
                    LabeledContent("Vendor", value: vendor)
                    if let price = ink.price {
                        LabeledContent("Price", value: price.formatted(.currency(code: "USD")))
                    }
                    if let date = ink.purchaseDate {
                        LabeledContent("Date", value: date.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let url = ink.purchaseURL {
                        Link("Purchase Link", destination: url)
                    }
                }
            }

            if !ink.notes.isEmpty {
                Section("Notes") {
                    Text(ink.notes)
                }
            }

            if let photo = ink.photo, let nsImage = NSImage(data: photo) {
                Section("Photo") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("\(ink.brand) \(ink.colorName)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            InkEditView(ink: ink)
        }
        .sheet(isPresented: $showingInkSheet) {
            InkThisPenSheet(presetPen: nil, presetInk: ink)
        }
        .sheet(isPresented: $showingSwatchSheet) {
            SwatchEditSheet(presetInk: ink, presetPaper: nil)
        }
    }
}
