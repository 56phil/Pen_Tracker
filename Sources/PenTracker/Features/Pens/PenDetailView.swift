import SwiftUI
import SwiftData

struct PenDetailView: View {
    @Bindable var pen: Pen
    @Environment(\.modelContext) private var context

    @State private var showingEdit = false
    @State private var showingInkSheet = false

    private var sortedInkings: [Inking] {
        pen.inkings.sorted { $0.filledDate > $1.filledDate }
    }

    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Brand", value: pen.brand)
                LabeledContent("Model", value: pen.model)
                LabeledContent("Color", value: pen.color)
                LabeledContent("Nib / Tip", value: pen.nibSizeOrTip)
                LabeledContent("Filling Mechanism", value: pen.fillingMechanism)
                LabeledContent("Status") { StatusBadge(status: pen.status) }
            }

            Section("Currently Inked") {
                if let inking = pen.currentInking, let ink = inking.ink {
                    HStack {
                        ColorSwatchView(hex: ink.colorHex)
                        Text("\(ink.brand) \(ink.colorName)")
                        Spacer()
                        Text(inking.filledDate, style: .date)
                            .foregroundStyle(.secondary)
                    }
                    Button("Empty This Pen") {
                        inking.emptiedDate = .now
                    }
                } else {
                    Text("Not currently inked").foregroundStyle(.secondary)
                }
                Button("Ink This Pen…") { showingInkSheet = true }
            }

            if !sortedInkings.isEmpty {
                Section("Inking History") {
                    ForEach(sortedInkings) { inking in
                        HStack {
                            ColorSwatchView(hex: inking.ink?.colorHex)
                            VStack(alignment: .leading) {
                                Text(inking.ink.map { "\($0.brand) \($0.colorName)" } ?? "Unknown ink")
                                Text(inking.filledDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let notes = inking.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if inking.isCurrent {
                                Text("Current").font(.caption).foregroundStyle(.green)
                            } else if let emptied = inking.emptiedDate {
                                Text("Until \(emptied.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if let vendor = pen.vendor, !vendor.isEmpty {
                Section("Purchase") {
                    LabeledContent("Vendor", value: vendor)
                    if let price = pen.price {
                        LabeledContent("Price", value: price.formatted(.currency(code: "USD")))
                    }
                    if let date = pen.purchaseDate {
                        LabeledContent("Date", value: date.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let url = pen.purchaseURL {
                        Link("Purchase Link", destination: url)
                    }
                }
            }

            if !pen.notes.isEmpty {
                Section("Notes") {
                    Text(pen.notes)
                }
            }

            if let photo = pen.photo, let nsImage = NSImage(data: photo) {
                Section("Photo") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("\(pen.brand) \(pen.model)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            PenEditView(pen: pen)
        }
        .sheet(isPresented: $showingInkSheet) {
            InkThisPenSheet(presetPen: pen, presetInk: nil)
        }
    }
}
