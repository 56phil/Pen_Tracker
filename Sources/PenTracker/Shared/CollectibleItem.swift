import Foundation
import SwiftData

/// The properties every collected item exposes to the shared list UI, which
/// uses them to search, filter, and sort. Settable purchase details live in
/// `PurchasableItem`, which the edit forms use.
protocol CollectibleItem: PersistentModel {
    var brand: String { get }
    var status: CollectionStatus { get }
    var rating: ItemRating? { get }
    var purchaseDate: Date? { get }
    var price: Decimal? { get }
    var createdAt: Date { get }
}

extension Pen: CollectibleItem {}
extension Ink: CollectibleItem {}
extension Paper: CollectibleItem {}
