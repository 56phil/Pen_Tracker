import SwiftUI
import SwiftData

struct PenEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let pen: Pen?

    @State private var brand = ""
    @State private var model = ""
    @State private var color = ""
    @State private var nibSizeOrTip = ""
    @State private var fillingMechanism = ""
    @State private var status: CollectionStatus = .inRotation
    @State private var purchaseDate: Date = .now
    @State private var hasPurchaseDate = false
    @State private var priceText = ""
    @State private var vendor = ""
    @State private var purchaseURLText = ""
    @State private var notes = ""
    @State private var photo: Data?

    private var isNew: Bool { pen == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $model)
                    TextField("Color", text: $color)
                    TextField("Nib / Tip (e.g. Fine, 1.1 Stub)", text: $nibSizeOrTip)
                    TextField("Filling Mechanism", text: $fillingMechanism)
                    Picker("Status", selection: $status) {
                        ForEach(CollectionStatus.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                }

                Section("Purchase") {
                    Toggle("Track Purchase Info", isOn: $hasPurchaseDate)
                    if hasPurchaseDate {
                        DatePicker("Date", selection: $purchaseDate, displayedComponents: .date)
                        TextField("Price", text: $priceText)
                        TextField("Vendor", text: $vendor)
                        TextField("Purchase URL", text: $purchaseURLText)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }

                Section("Photo") {
                    ImagePickerButton(photo: $photo)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "Add Pen" : "Edit Pen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(brand.isEmpty || model.isEmpty)
                }
            }
        }
        .onAppear(perform: loadIfEditing)
        .frame(minWidth: 420, minHeight: 520)
    }

    private func loadIfEditing() {
        guard let pen else { return }
        brand = pen.brand
        model = pen.model
        color = pen.color
        nibSizeOrTip = pen.nibSizeOrTip
        fillingMechanism = pen.fillingMechanism
        status = pen.status
        if let date = pen.purchaseDate {
            hasPurchaseDate = true
            purchaseDate = date
        }
        if let price = pen.price {
            priceText = price.priceText
        }
        vendor = pen.vendor ?? ""
        purchaseURLText = pen.purchaseURL?.absoluteString ?? ""
        notes = pen.notes
        photo = pen.photo
    }

    private func save() {
        let price = Decimal(priceText: priceText)
        let url = purchaseURLText.isEmpty ? nil : URL(string: purchaseURLText)

        if let pen {
            pen.brand = brand
            pen.model = model
            pen.color = color
            pen.nibSizeOrTip = nibSizeOrTip
            pen.fillingMechanism = fillingMechanism
            pen.status = status
            pen.purchaseDate = hasPurchaseDate ? purchaseDate : nil
            pen.price = hasPurchaseDate ? price : nil
            pen.vendor = hasPurchaseDate ? vendor : nil
            pen.purchaseURL = hasPurchaseDate ? url : nil
            pen.notes = notes
            pen.photo = photo
        } else {
            let newPen = Pen(brand: brand, model: model, color: color,
                              nibSizeOrTip: nibSizeOrTip, fillingMechanism: fillingMechanism,
                              status: status,
                              purchaseDate: hasPurchaseDate ? purchaseDate : nil,
                              price: hasPurchaseDate ? price : nil,
                              vendor: hasPurchaseDate ? vendor : nil,
                              purchaseURL: hasPurchaseDate ? url : nil,
                              notes: notes, photo: photo)
            context.insert(newPen)
        }
        dismiss()
    }
}
