import SwiftUI

struct PaperListView: View {
    var body: some View {
        CollectionListView<Paper, PaperRowView, PaperEditView, PaperDetailView>(
            navigationTitle: "Paper",
            searchPrompt: "Search paper",
            addLabel: "Add Paper",
            emptyTitle: "No Paper Yet",
            emptySystemImage: "doc.plaintext",
            emptyDescription: "Add your first paper to get started.",
            matchesSearch: { paper, text in
                paper.brand.localizedCaseInsensitiveContains(text) ||
                paper.lineName.localizedCaseInsensitiveContains(text)
            },
            row: { paper in PaperRowView(paper: paper) },
            addSheet: { PaperEditView(paper: nil) },
            detail: { paper in PaperDetailView(paper: paper) }
        )
    }
}
