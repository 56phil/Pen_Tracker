import SwiftUI

struct ItemRatingPicker: View {
    @Binding var rating: ItemRating?

    var body: some View {
        Picker("Rating", selection: $rating) {
            Text("Not Rated").tag(ItemRating?.none)
            ForEach(ItemRating.allCases) { rating in
                Text(rating.label).tag(ItemRating?.some(rating))
            }
        }
    }
}
