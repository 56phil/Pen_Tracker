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
    @State private var purchaseInfo = PurchaseInfoFormState()
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

                PurchaseInfoEditSection(state: $purchaseInfo)

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
        purchaseInfo.load(from: pen)
        notes = pen.notes
        photo = pen.photo
    }

    private func save() {
        if let pen {
            pen.brand = brand
            pen.model = model
            pen.color = color
            pen.nibSizeOrTip = nibSizeOrTip
            pen.fillingMechanism = fillingMechanism
            pen.status = status
            purchaseInfo.apply(to: pen)
            pen.notes = notes
            pen.photo = photo
        } else {
            let newPen = Pen(brand: brand, model: model, color: color,
                              nibSizeOrTip: nibSizeOrTip, fillingMechanism: fillingMechanism,
                              status: status,
                              purchaseDate: purchaseInfo.resolvedDate,
                              price: purchaseInfo.resolvedPrice,
                              vendor: purchaseInfo.resolvedVendor,
                              purchaseURL: purchaseInfo.resolvedURL,
                              notes: notes, photo: photo)
            context.insert(newPen)
        }
        dismiss()
    }
}
