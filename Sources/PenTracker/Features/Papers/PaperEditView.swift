import SwiftUI
import SwiftData

struct PaperEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let paper: Paper?

    @State private var brand = ""
    @State private var lineName = ""
    @State private var weightText = ""
    @State private var colorOrFinish = ""
    @State private var format = ""
    @State private var quantity = 1
    @State private var status: CollectionStatus = .inRotation
    @State private var rating: ItemRating?
    @State private var purchaseInfo = PurchaseInfoFormState()
    @State private var notes = ""
    @State private var photo: Data?

    private var isNew: Bool { paper == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Brand", text: $brand)
                    TextField("Line", text: $lineName)
                    TextField("Format (e.g. A5 Notebook)", text: $format)
                    TextField("Weight (gsm)", text: $weightText)
                    TextField("Color / Finish", text: $colorOrFinish)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 0...999)
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
            .navigationTitle(isNew ? "Add Paper" : "Edit Paper")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(brand.isEmpty || format.isEmpty)
                }
            }
        }
        .onAppear(perform: loadIfEditing)
        .frame(minWidth: 420, minHeight: 520)
    }

    private func loadIfEditing() {
        guard let paper else { return }
        brand = paper.brand
        lineName = paper.lineName
        if let weight = paper.weightGSM {
            weightText = String(weight)
        }
        colorOrFinish = paper.colorOrFinish ?? ""
        format = paper.format
        quantity = paper.quantity
        status = paper.status
        rating = paper.rating
        purchaseInfo.load(from: paper)
        notes = paper.notes
        photo = paper.photo
    }

    private func save() {
        let weight = Int(weightText)
        let finish = colorOrFinish.isEmpty ? nil : colorOrFinish

        if let paper {
            paper.brand = brand
            paper.lineName = lineName
            paper.weightGSM = weight
            paper.colorOrFinish = finish
            paper.format = format
            paper.quantity = quantity
            paper.status = status
            paper.rating = rating
            purchaseInfo.apply(to: paper)
            paper.notes = notes
            paper.photo = photo
        } else {
            let newPaper = Paper(brand: brand, lineName: lineName, weightGSM: weight,
                                 colorOrFinish: finish, format: format, quantity: quantity,
                                 status: status, rating: rating,
                                 purchaseDate: purchaseInfo.resolvedDate,
                                 price: purchaseInfo.resolvedPrice,
                                 vendor: purchaseInfo.resolvedVendor,
                                 purchaseURL: purchaseInfo.resolvedURL,
                                 notes: notes, photo: photo)
            context.insert(newPaper)
        }
        dismiss()
    }
}
