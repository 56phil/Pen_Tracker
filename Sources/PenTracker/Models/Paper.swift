import Foundation
import SwiftData

@Model
final class Paper {
 @Attribute(.unique) var id: UUID
 var brand: String
 var lineName: String
 var weightGSM: Int?
 var colorOrFinish: String?
 var format: String
 var quantity: Int
 var status: CollectionStatus
 var rating: ItemRating?
 var purchaseDate: Date?
 var price: Decimal?
 var vendor: String?
 var purchaseURL: URL?
 var notes: String
 @Attribute(.externalStorage) var photo: Data?
 var createdAt: Date

 @Relationship(deleteRule: .cascade, inverse: \Swatch.paper)
 var swatches: [Swatch] = []

 init(
  brand: String, lineName: String, weightGSM: Int? = nil, colorOrFinish: String? = nil,
  format: String, quantity: Int = 1, status: CollectionStatus = .inRotation,
  rating: ItemRating? = nil,
  purchaseDate: Date? = nil, price: Decimal? = nil, vendor: String? = nil,
  purchaseURL: URL? = nil, notes: String = "", photo: Data? = nil
 ) {
  self.id = UUID()
  self.brand = brand
  self.lineName = lineName
  self.weightGSM = weightGSM
  self.colorOrFinish = colorOrFinish
  self.format = format
  self.quantity = quantity
  self.status = status
  self.rating = rating
  self.purchaseDate = purchaseDate
  self.price = price
  self.vendor = vendor
  self.purchaseURL = purchaseURL
  self.notes = notes
  self.photo = photo
  self.createdAt = .now
 }
}
