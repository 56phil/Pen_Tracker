import SwiftUI

struct StatusBadge: View {
    let status: CollectionStatus

    private var color: Color {
        switch status {
        case .wishlist: return .purple
        case .inRotation: return .green
        case .stored: return .blue
        case .retired: return .gray
        }
    }

    var body: some View {
        Text(status.label)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
