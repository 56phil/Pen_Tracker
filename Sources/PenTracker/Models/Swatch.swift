import Foundation
import SwiftData

@Model
final class Swatch {
    @Attribute(.unique) var id: UUID
    var ink: Ink?
    var paper: Paper?
    var dateTested: Date
    var rating: Int?
    var notes: String?
    @Attribute(.externalStorage) var photo: Data?

    init(ink: Ink?, paper: Paper?, dateTested: Date = .now, rating: Int? = nil,
         notes: String? = nil, photo: Data? = nil) {
        self.id = UUID()
        self.ink = ink
        self.paper = paper
        self.dateTested = dateTested
        self.rating = rating
        self.notes = notes
        self.photo = photo
    }
}
