import SwiftUI

struct RatingView: View {
    @Binding var rating: Int?
    var maxRating: Int = 5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: (rating ?? 0) >= star ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        rating = (rating == star) ? nil : star
                    }
            }
            if rating != nil {
                Button {
                    rating = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RatingDisplayView: View {
    let rating: Int?
    var maxRating: Int = 5

    var body: some View {
        if let rating {
            HStack(spacing: 2) {
                ForEach(1...maxRating, id: \.self) { star in
                    Image(systemName: rating >= star ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}
