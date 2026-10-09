import SwiftData
import SwiftUI

/// A brand text field paired with a menu of the brands already in the
/// collection.
///
/// The field stays free-form, so a maker the collection has never held is
/// still typeable. The menu is what keeps a second spelling of an existing
/// brand out of the store: typing "Asvine" by hand is how "Assvine" happens,
/// and picking it from a list is not.
struct BrandField: View {
    @Binding var brand: String

    @Query private var pens: [Pen]
    @Query private var inks: [Ink]
    @Query private var papers: [Paper]

    @State private var showingManager = false

    private var inventory: BrandInventory {
        BrandInventory(pens: pens, inks: inks, papers: papers)
    }

    var body: some View {
        HStack(spacing: 6) {
            TextField("Brand", text: $brand)
            Menu {
                if inventory.isEmpty {
                    Text("No Brands Yet")
                } else {
                    ForEach(inventory.entries) { entry in
                        Button {
                            brand = entry.name
                        } label: {
                            if entry.name == brand {
                                Label(entry.name, systemImage: "checkmark")
                            } else {
                                Text(entry.name)
                            }
                        }
                    }
                }
                Divider()
                Button("Manage Brands…") { showingManager = true }
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.small)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Choose an existing brand")
            .accessibilityLabel("Choose an existing brand")
        }
        .sheet(isPresented: $showingManager) {
            BrandManagerView()
        }
    }
}
