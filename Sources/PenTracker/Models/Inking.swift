import Foundation
import SwiftData

@Model
final class Inking {
 @Attribute(.unique) var id: UUID
 var pen: Pen?
 var ink: Ink?
 var filledDate: Date
 var emptiedDate: Date?
 var notes: String?
 var rating: ItemRating?

 var isCurrent: Bool { emptiedDate == nil }

 init(
  pen: Pen?, ink: Ink?, filledDate: Date = .now, emptiedDate: Date? = nil,
  notes: String? = nil, rating: ItemRating? = nil
 ) {
  self.id = UUID()
  self.pen = pen
  self.ink = ink
  self.filledDate = filledDate
  self.emptiedDate = emptiedDate
  self.notes = notes
  self.rating = rating
 }
}
