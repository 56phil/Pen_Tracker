import SwiftUI
import SwiftData

struct InkEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let ink: Ink?

    @State private var brand = ""
    @State private var lineName = ""
    @State private var colorName = ""
    @State private var colorHex = ""
    @State private var packageType: InkPackageType = .bottle
    @State private var volumeText = ""
    @State private var quantity = 1
    @State private var status: CollectionStatus = .inRotation
    @State private var rating: ItemRating?
    @State private var purchaseInfo = PurchaseInfoFormState()
    @State private var notes = ""
    @State private var photo: Data?

    private var isNew: Bool { ink == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Brand", text: $brand)
                    TextField("Line (e.g. Iroshizuku)", text: $lineName)
                    TextField("Color Name", text: $colorName)
                    HStack {
                        TextField("Hex (e.g. 1B4B8A)", text: $colorHex)
                        ColorSwatchView(hex: colorHex, size: 20)
                    }
                    Picker("Package", selection: $packageType) {
                        ForEach(InkPackageType.allCases) { p in
                            Text(p.label).tag(p)
                        }
                    }
                    TextField("Volume (mL)", text: $volumeText)
                    Stepper("Quantity Owned: \(quantity)", value: $quantity, in: 0...99)
                    Picker("Status", selection: $status) {
                        ForEach(CollectionStatus.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                }

                Section("Rating") {
                    ItemRatingPicker(rating: $rating)
                }

                PurchaseInfoEditSection(state: $purchaseInfo)

                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }

                Section("Photo") {
                    ImagePickerButton(photo: $photo)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "Add Ink" : "Edit Ink")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(brand.isEmpty || colorName.isEmpty)
                }
            }
        }
        .onAppear(perform: loadIfEditing)
        .frame(minWidth: 420, minHeight: 560)
    }

    private func loadIfEditing() {
        guard let ink else { return }
        brand = ink.brand
        lineName = ink.lineName
        colorName = ink.colorName
        colorHex = ink.colorHex ?? ""
        packageType = ink.packageType
        if let volume = ink.volumeML {
            volumeText = String(format: "%.0f", volume)
        }
        quantity = ink.quantity
        status = ink.status
        rating = ink.rating
        purchaseInfo.load(from: ink)
        notes = ink.notes
        photo = ink.photo
    }

    private func save() {
        let volume = Double(volumeText)
        let hex = colorHex.isEmpty ? nil : colorHex

        if let ink {
            ink.brand = brand
            ink.lineName = lineName
            ink.colorName = colorName
            ink.colorHex = hex
            ink.packageType = packageType
            ink.volumeML = volume
            ink.quantity = quantity
            ink.status = status
            ink.rating = rating
            purchaseInfo.apply(to: ink)
            ink.notes = notes
            ink.photo = photo
        } else {
            let newInk = Ink(brand: brand, lineName: lineName, colorName: colorName,
                             colorHex: hex, packageType: packageType, volumeML: volume,
                             quantity: quantity, status: status, rating: rating,
                             purchaseDate: purchaseInfo.resolvedDate,
                             price: purchaseInfo.resolvedPrice,
                             vendor: purchaseInfo.resolvedVendor,
                             purchaseURL: purchaseInfo.resolvedURL,
                             notes: notes, photo: photo)
            context.insert(newInk)
        }
        dismiss()
    }
}
