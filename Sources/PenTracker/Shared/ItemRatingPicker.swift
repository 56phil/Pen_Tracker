import SwiftUI

struct ItemRatingPicker: View {
        @Binding var rating: ItemRating?

        var body: some View {
                ArrowPicker("Rating", selection: $rating, options: [nil] + ItemRating.allCases) {
                        Text("Not Rated").tag(ItemRating?.none)
                        ForEach(ItemRating.allCases) { rating in
                                Text(rating.label).tag(ItemRating?.some(rating))
                        }
                }
        }
}
