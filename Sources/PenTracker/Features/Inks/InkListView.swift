import SwiftUI
import SwiftData

struct InkListView: View {
    @Environment(\.modelContext) private var context
    @State private var inks: [Ink] = []

    var body: some View {
        CollectionListView<Ink, InkRowView, InkEditView, InkDetailView>(
            items: $inks,
            refresh: fetchInks,
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
        .onAppear(perform: fetchInks)
    }

    private func fetchInks() {
        let descriptor = FetchDescriptor<Ink>(sortBy: [SortDescriptor(\.brand)])
        inks = (try? context.fetch(descriptor)) ?? []
    }
}
