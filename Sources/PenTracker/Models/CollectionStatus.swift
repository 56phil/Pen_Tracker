import Foundation

enum CollectionStatus: String, Codable, CaseIterable, Identifiable {
    case wishlist, inRotation, stored, retired

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wishlist: return "Wishlist"
        case .inRotation: return "In Rotation"
        case .stored: return "Stored"
        case .retired: return "Retired"
        }
    }
}

enum InkPackageType: String, Codable, CaseIterable, Identifiable {
    case bottle, sample, cartridge

    var id: String { rawValue }

    var label: String {
        switch self {
        case .bottle: return "Bottle"
        case .sample: return "Sample"
        case .cartridge: return "Cartridge"
        }
    }
}
