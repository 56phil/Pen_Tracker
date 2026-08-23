import SwiftUI
import SwiftData

struct PaperListView: View {
    @Environment(\.modelContext) private var context
    @State private var papers: [Paper] = []

    var body: some View {
        CollectionListView<Paper, PaperRowView, PaperEditView, PaperDetailView>(
            items: $papers,
            refresh: fetchPapers,
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
        .onAppear(perform: fetchPapers)
    }

    private func fetchPapers() {
        let descriptor = FetchDescriptor<Paper>(sortBy: [SortDescriptor(\.brand)])
        papers = (try? context.fetch(descriptor)) ?? []
    }
}
