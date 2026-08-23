import Foundation
import SwiftData
import SwiftUI

struct InkDetailView: View {
    @Bindable var ink: Ink
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingInkSheet = false
    @State private var showingSwatchSheet = false
    @State private var editingInking: Inking?

    private var sortedInkings: [Inking] {
        ink.inkings.sorted { $0.filledDate > $1.filledDate }
    }

    private var sortedSwatches: [Swatch] {
        ink.swatches.sorted { $0.dateTested > $1.dateTested }
    }

    var body: some View {
        Form {
            Section("Details") {
                KeyboardFocusableRow(label: "Brand") { Text(ink.brand) }
                KeyboardFocusableRow(label: "Line") { Text(ink.lineName) }
                KeyboardFocusableRow(label: "Color") { Text(ink.colorName) }
                KeyboardFocusableRow(label: "Swatch") {
                    ColorSwatchView(hex: ink.colorHex, size: 20)
                }
                KeyboardFocusableRow(label: "Package") { Text(ink.packageType.label) }
                if let volume = ink.volumeML {
                    KeyboardFocusableRow(label: "Volume") { Text("\(Int(volume)) mL") }
                }
                KeyboardFocusableRow(label: "Quantity Owned") { Text("\(ink.quantity)") }
                KeyboardFocusableRow(label: "Status") { StatusBadge(status: ink.status) }
                KeyboardFocusableRow(label: "Rating") { RatingBadgeView(rating: ink.rating) }
            }

            Section("Used In") {
                Button("Ink a Pen With This…") { showingInkSheet = true }
                    .help("Ink This Pen (⌘I)")
                ForEach(sortedInkings) { inking in
                    if let pen = inking.pen {
                        Button {
                            editingInking = inking
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(pen.brand) \(pen.model)")
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
                                } else {
                                    Text(inking.filledDate, style: .date)
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

            Section("Swatch Tests") {
                Button("Swatch on Paper…") { showingSwatchSheet = true }
                    .help("Swatch on Paper (⌘⇧W)")
                ForEach(sortedSwatches) { swatch in
                    if let paper = swatch.paper {
                        HStack {
                            Text("\(paper.brand) \(paper.lineName)")
                            Spacer()
                            RatingBadgeView(rating: swatch.rating)
                        }
                    }
                }
            }

            if let vendor = ink.vendor, !vendor.isEmpty {
                PurchaseInfoView(
                    vendor: vendor, price: ink.price, date: ink.purchaseDate, url: ink.purchaseURL)
            }

            if !ink.notes.isEmpty {
                Section("Notes") {
                    Text(ink.notes)
                }
            }

            PhotoSection(photo: ink.photo)
        }
        .formStyle(.grouped)
        .navigationTitle("\(ink.brand) \(ink.colorName)")
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
        .keyboardInkAction { showingInkSheet = true }
        .keyboardSwatchAction { showingSwatchSheet = true }
        .keyboardBackAction { dismiss() }
        .sheet(isPresented: $showingEdit) {
            InkEditView(ink: ink)
        }
        .sheet(isPresented: $showingInkSheet) {
            InkThisPenSheet(presetPen: nil, presetInk: ink)
        }
        .sheet(item: $editingInking) { inking in
            InkingEditSheet(inking: inking)
        }
        .sheet(isPresented: $showingSwatchSheet) {
            SwatchEditSheet(presetInk: ink, presetPaper: nil)
        }
        .deleteToolbarButton(itemDescription: "\(ink.brand) \(ink.colorName)") {
            context.delete(ink)
        }
    }
}
