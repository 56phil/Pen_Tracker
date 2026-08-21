import SwiftUI

struct PurchaseInfoView: View {
    let vendor: String
    let price: Decimal?
    let date: Date?
    let url: URL?

    var body: some View {
        Section("Purchase") {
            LabeledContent("Vendor", value: vendor)
            if let price {
                LabeledContent("Price", value: price.formatted(.currency(code: "USD")))
            }
            if let date {
                LabeledContent("Date", value: date.abbreviated)
            }
            if let url {
                Link("Purchase Link", destination: url)
            }
        }
    }
}
