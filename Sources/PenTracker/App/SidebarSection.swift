import Foundation

enum SidebarSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard, pens, inks, papers, swatches

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .pens: return "Pens"
        case .inks: return "Inks"
        case .papers: return "Paper"
        case .swatches: return "Swatches"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .pens: return "pencil"
        case .inks: return "drop.fill"
        case .papers: return "doc.plaintext"
        case .swatches: return "paintpalette"
        }
    }
}
