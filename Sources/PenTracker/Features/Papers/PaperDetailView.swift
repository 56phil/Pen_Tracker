import SwiftData
import SwiftUI

struct PaperDetailView: View {
    @Bindable var paper: Paper
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingSwatchSheet = false

    private var sortedSwatches: [Swatch] {
        paper.swatches.sorted { $0.dateTested > $1.dateTested }
    }

    var body: some View {
        Form {
            Section("Details") {
                KeyboardFocusableRow(label: "Brand") { Text(paper.brand) }
                KeyboardFocusableRow(label: "Line") { Text(paper.lineName) }
                KeyboardFocusableRow(label: "Format") { Text(paper.format) }
                if let gsm = paper.weightGSM {
                    KeyboardFocusableRow(label: "Weight") { Text("\(gsm) gsm") }
                }
                if let finish = paper.colorOrFinish, !finish.isEmpty {
                    KeyboardFocusableRow(label: "Color / Finish") { Text(finish) }
                }
                KeyboardFocusableRow(label: "Quantity") { Text("\(paper.quantity)") }
                KeyboardFocusableRow(label: "Status") { StatusBadge(status: paper.status) }
                KeyboardFocusableRow(label: "Rating") { RatingBadgeView(rating: paper.rating) }
            }

            Section("Swatch Tests") {
                Button("Swatch an Ink on This…") { showingSwatchSheet = true }
                    .help("Swatch on Paper (⌘⇧W)")
                ForEach(sortedSwatches) { swatch in
                    if let ink = swatch.ink {
                        HStack {
                            ColorSwatchView(hex: ink.colorHex)
                            Text("\(ink.brand) \(ink.colorName)")
                            Spacer()
                            RatingBadgeView(rating: swatch.rating)
                        }
                    }
                }
            }

            if let vendor = paper.vendor, !vendor.isEmpty {
                PurchaseInfoView(
                    vendor: vendor, price: paper.price, date: paper.purchaseDate,
                    url: paper.purchaseURL)
            }

            if !paper.notes.isEmpty {
                Section("Notes") {
                    Text(paper.notes)
                }
            }

            PhotoSection(photo: paper.photo)
        }
        .formStyle(.grouped)
        .navigationTitle("\(paper.brand) \(paper.lineName)")
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
        .keyboardSwatchAction { showingSwatchSheet = true }
        .keyboardBackAction { dismiss() }
        .sheet(isPresented: $showingEdit) {
            PaperEditView(paper: paper)
        }
        .sheet(isPresented: $showingSwatchSheet) {
            SwatchEditSheet(presetInk: nil, presetPaper: paper)
        }
        .deleteToolbarButton(itemDescription: "\(paper.brand) \(paper.lineName)") {
            context.delete(paper)
        }
    }
}
