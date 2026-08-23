import Foundation
import SwiftData

@Model
final class Ink {
 @Attribute(.unique) var id: UUID
 var brand: String
 var lineName: String
 var colorName: String
 var colorHex: String?
 var packageType: InkPackageType
 var volumeML: Double?
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

 @Relationship(deleteRule: .nullify, inverse: \Inking.ink)
 var inkings: [Inking] = []

 @Relationship(deleteRule: .cascade, inverse: \Swatch.ink)
 var swatches: [Swatch] = []

 init(
  brand: String, lineName: String, colorName: String, colorHex: String? = nil,
  packageType: InkPackageType = .bottle, volumeML: Double? = nil, quantity: Int = 1,
  status: CollectionStatus = .inRotation, rating: ItemRating? = nil,
  purchaseDate: Date? = nil, price: Decimal? = nil,
  vendor: String? = nil, purchaseURL: URL? = nil, notes: String = "", photo: Data? = nil
 ) {
  self.id = UUID()
  self.brand = brand
  self.lineName = lineName
  self.colorName = colorName
  self.colorHex = colorHex
  self.packageType = packageType
  self.volumeML = volumeML
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
