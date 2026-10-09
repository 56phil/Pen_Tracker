import SwiftData
import SwiftUI

/// Lists every brand in the collection and lets the list itself be corrected:
/// rename one spelling into another, or remove the items carrying it.
///
/// Deliberately not a list the user authors from scratch. A brand exists here
/// exactly while some item uses it, so the list cannot drift away from the
/// collection it describes. `czxwyst` and `Moonman` need no curating.
struct BrandManagerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var pens: [Pen]
    @Query private var inks: [Ink]
    @Query private var papers: [Paper]

    @State private var renameTarget: BrandEntry?
    @State private var renameText = ""
    @State private var removeTarget: BrandEntry?

    private var inventory: BrandInventory {
        BrandInventory(pens: pens, inks: inks, papers: papers)
    }

    var body: some View {
        NavigationStack {
            Group {
                if inventory.isEmpty {
                    ContentUnavailableView(
                        "No Brands Yet",
                        systemImage: "tag",
                        description: Text("Brands appear here as you add pens, inks, and paper."))
                } else {
                    List {
                        ForEach(inventory.entries) { entry in
                            row(for: entry)
                        }
                    }
                }
            }
            .navigationTitle("Brands")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Rename Brand", isPresented: renaming, presenting: renameTarget) { entry in
                TextField("Brand", text: $renameText)
                Button("Rename") { rename(entry.name, to: renameText) }
                Button("Cancel", role: .cancel) {}
            } message: { entry in
                Text("Every item with the brand “\(entry.name)” will be renamed.")
            }
            .alert("Remove Brand", isPresented: removing, presenting: removeTarget) { entry in
                Button("Remove \(entry.count) Items", role: .destructive) {
                    removeItems(brand: entry.name)
                }
                Button("Cancel", role: .cancel) {}
            } message: { entry in
                Text(
                    "This deletes every pen, ink, and paper with the brand “\(entry.name)”, along with their inkings and swatches."
                )
            }
        }
        .frame(minWidth: 420, minHeight: 420)
    }

    private func row(for entry: BrandEntry) -> some View {
        HStack {
            Text(entry.name)
            Spacer()
            Text(entry.itemCountText)
                .foregroundStyle(.secondary)
            Menu {
                Button("Rename…") {
                    renameText = entry.name
                    renameTarget = entry
                }
                Button("Remove All Items…", role: .destructive) {
                    removeTarget = entry
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .accessibilityLabel("Actions for \(entry.name)")
        }
    }

    private var renaming: Binding<Bool> {
        Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } })
    }

    private var removing: Binding<Bool> {
        Binding(
            get: { removeTarget != nil },
            set: { if !$0 { removeTarget = nil } })
    }

    private func rename(_ old: String, to new: String) {
        let trimmed = new.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != old else { return }
        for pen in pens where pen.brand == old { pen.brand = trimmed }
        for ink in inks where ink.brand == old { ink.brand = trimmed }
        for paper in papers where paper.brand == old { paper.brand = trimmed }
    }

    private func removeItems(brand: String) {
        for pen in pens where pen.brand == brand { context.delete(pen) }
        for ink in inks where ink.brand == brand { context.delete(ink) }
        for paper in papers where paper.brand == brand { context.delete(paper) }
    }
}
