import Foundation

struct PurchaseInfoFormState {
    var isTracked = false
    var date: Date = .now
    var priceText = ""
    var vendor = ""
    var urlText = ""

    var resolvedDate: Date? { isTracked ? date : nil }
    var resolvedPrice: Decimal? { isTracked ? Decimal(priceText: priceText) : nil }
    var resolvedVendor: String? { isTracked ? vendor : nil }
    var resolvedURL: URL? {
        guard isTracked, !urlText.isEmpty else { return nil }
        return URL(string: urlText)
    }

    mutating func load(from item: PurchasableItem) {
        if let date = item.purchaseDate {
            isTracked = true
            self.date = date
        }
        if let price = item.price {
            priceText = price.priceText
        }
        vendor = item.vendor ?? ""
        urlText = item.purchaseURL?.absoluteString ?? ""
    }

    func apply(to item: PurchasableItem) {
        item.purchaseDate = resolvedDate
        item.price = resolvedPrice
        item.vendor = resolvedVendor
        item.purchaseURL = resolvedURL
    }
}
