import SwiftUI

struct PurchaseInfoEditSection: View {
    @Binding var state: PurchaseInfoFormState

    var body: some View {
        Section("Purchase") {
            Toggle("Track Purchase Info", isOn: $state.isTracked)
            if state.isTracked {
                DatePicker("Date", selection: $state.date, displayedComponents: .date)
                TextField("Price", text: $state.priceText)
                TextField("Vendor", text: $state.vendor)
                TextField("Purchase URL", text: $state.urlText)
            }
        }
    }
}
