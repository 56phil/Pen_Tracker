import Foundation

/// Overall assessment of a collected item, from best to worst.
enum ItemRating: Int, Codable, CaseIterable, Identifiable {
    case outstanding, satisfactory, barelySatisfactory, unsatisfactory

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .outstanding: return "Outstanding"
        case .satisfactory: return "Satisfactory"
        case .barelySatisfactory: return "Barely Satisfactory"
        case .unsatisfactory: return "Unsatisfactory"
        }
    }
}
