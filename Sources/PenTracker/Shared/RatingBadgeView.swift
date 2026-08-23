import SwiftUI

struct RatingBadgeView: View {
    let rating: ItemRating?

    private var color: Color {
        guard let rating else { return .gray }
        switch rating {
        case .outstanding: return .green
        case .satisfactory: return .blue
        case .barelySatisfactory: return .orange
        case .unsatisfactory: return .red
        }
    }

    var body: some View {
        if let rating {
            Text(rating.label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(Capsule())
        }
    }
}
