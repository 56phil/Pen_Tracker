import SwiftData
import SwiftUI

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
    @State private var rating: ItemRating?
    @State private var purchaseInfo = PurchaseInfoFormState()
    @State private var notes = ""
    @State private var photo: Data?

    private var isNew: Bool { pen == nil }

    private var canSave: Bool { !brand.isEmpty && !model.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $model)
                    TextField("Color", text: $color)
                    TextField("Nib / Tip (e.g. Fine, 1.1 Stub)", text: $nibSizeOrTip)
                    TextField("Filling Mechanism", text: $fillingMechanism)
                    ArrowPicker("Status", selection: $status, options: CollectionStatus.allCases) {
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
            .navigationTitle(isNew ? "Add Pen" : "Edit Pen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .help("Cancel (Esc)")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                        .help("Save (⌘S)")
                }
            }
        }
        .onAppear(perform: loadIfEditing)
        .frame(minWidth: 420, minHeight: 520)
        .formKeyboardShortcuts(
            save: { if canSave { save() } },
            cancel: { dismiss() })
    }

    private func loadIfEditing() {
        guard let pen else { return }
        brand = pen.brand
        model = pen.model
        color = pen.color
        nibSizeOrTip = pen.nibSizeOrTip
        fillingMechanism = pen.fillingMechanism
        status = pen.status
        rating = pen.rating
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
            pen.rating = rating
            purchaseInfo.apply(to: pen)
            pen.notes = notes
            pen.photo = photo
        } else {
            let newPen = Pen(
                brand: brand, model: model, color: color,
                nibSizeOrTip: nibSizeOrTip, fillingMechanism: fillingMechanism,
                status: status, rating: rating,
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
