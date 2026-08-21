import Foundation
import SwiftData

@Model
final class Pen {
    @Attribute(.unique) var id: UUID
    var brand: String
    var model: String
    var color: String
    var nibSizeOrTip: String
    var fillingMechanism: String
    var status: CollectionStatus
    var purchaseDate: Date?
    var price: Decimal?
    var vendor: String?
    var purchaseURL: URL?
    var notes: String
    @Attribute(.externalStorage) var photo: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Inking.pen)
    var inkings: [Inking] = []

    var currentInking: Inking? {
        inkings.filter { $0.isCurrent }.sorted { $0.filledDate > $1.filledDate }.first
    }

    init(brand: String, model: String, color: String, nibSizeOrTip: String,
         fillingMechanism: String, status: CollectionStatus = .inRotation,
         purchaseDate: Date? = nil, price: Decimal? = nil, vendor: String? = nil,
         purchaseURL: URL? = nil, notes: String = "", photo: Data? = nil) {
        self.id = UUID()
        self.brand = brand
        self.model = model
        self.color = color
        self.nibSizeOrTip = nibSizeOrTip
        self.fillingMechanism = fillingMechanism
        self.status = status
        self.purchaseDate = purchaseDate
        self.price = price
        self.vendor = vendor
        self.purchaseURL = purchaseURL
        self.notes = notes
        self.photo = photo
        self.createdAt = .now
    }
}
