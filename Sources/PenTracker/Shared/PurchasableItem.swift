import Foundation

protocol PurchasableItem: AnyObject {
    var purchaseDate: Date? { get set }
    var price: Decimal? { get set }
    var vendor: String? { get set }
    var purchaseURL: URL? { get set }
}

extension Pen: PurchasableItem {}
extension Ink: PurchasableItem {}
extension Paper: PurchasableItem {}
