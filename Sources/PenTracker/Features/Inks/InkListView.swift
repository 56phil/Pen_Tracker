import SwiftUI

struct InkListView: View {
    var body: some View {
        CollectionListView<Ink, InkRowView, InkEditView, InkDetailView>(
            navigationTitle: "Inks",
            searchPrompt: "Search inks",
            addLabel: "Add Ink",
            emptyTitle: "No Inks Yet",
            emptySystemImage: "drop",
            emptyDescription: "Add your first ink to get started.",
            matchesSearch: { ink, text in
                ink.brand.localizedCaseInsensitiveContains(text) ||
                ink.colorName.localizedCaseInsensitiveContains(text)
            },
            row: { ink in InkRowView(ink: ink) },
            addSheet: { InkEditView(ink: nil) },
            detail: { ink in InkDetailView(ink: ink) }
        )
    }
}
