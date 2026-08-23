import SwiftData
import SwiftUI

struct PenDetailView: View {
    @Bindable var pen: Pen
    @Environment(\.modelContext) private var context

    @State private var showingEdit = false
    @State private var showingInkSheet = false
    @State private var editingInking: Inking?

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
                LabeledContent("Rating") { RatingBadgeView(rating: pen.rating) }
                if let inking = pen.currentInking, let ink = inking.ink {
                    LabeledContent("Ink") {
                        HStack {
                            ColorSwatchView(hex: ink.colorHex)
                            Text("\(ink.brand) \(ink.colorName)")
                        }
                    }
                }
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
                        Button {
                            editingInking = inking
                        } label: {
                            HStack {
                                ColorSwatchView(hex: inking.ink?.colorHex)
                                VStack(alignment: .leading) {
                                    Text(
                                        inking.ink.map { "\($0.brand) \($0.colorName)" }
                                            ?? "Unknown ink")
                                    Text(inking.filledDate, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let notes = inking.notes, !notes.isEmpty {
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    RatingBadgeView(rating: inking.rating)
                                        .padding(.top, 2)
                                }
                                Spacer()
                                if inking.isCurrent {
                                    Text("Current").font(.caption).foregroundStyle(.green)
                                } else if let emptied = inking.emptiedDate {
                                    Text("Until \(emptied.abbreviated)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if let vendor = pen.vendor, !vendor.isEmpty {
                PurchaseInfoView(
                    vendor: vendor, price: pen.price, date: pen.purchaseDate, url: pen.purchaseURL)
            }

            if !pen.notes.isEmpty {
                Section("Notes") {
                    Text(pen.notes)
                }
            }

            PhotoSection(photo: pen.photo)
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
        .sheet(item: $editingInking) { inking in
            InkingEditSheet(inking: inking)
        }
        .deleteToolbarButton(itemDescription: "\(pen.brand) \(pen.model)") {
            context.delete(pen)
        }
    }
}
