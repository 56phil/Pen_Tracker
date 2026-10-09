import SwiftData
import SwiftUI

struct InkListView: View {
    @Environment(\.modelContext) private var context
    @State private var inks: [Ink] = []
    @Binding var path: NavigationPath

    var body: some View {
        CollectionListView<Ink, InkRowView, InkEditView, InkDetailView>(
            path: $path,
            items: $inks,
            refresh: fetchInks,
            navigationTitle: "Inks",
            searchPrompt: "Search inks",
            addLabel: "Add Ink",
            emptyTitle: "No Inks Yet",
            emptySystemImage: "drop",
            emptyDescription: "Add your first ink to get started.",
            matchesSearch: { ink, text in
                ink.brand.localizedCaseInsensitiveContains(text)
                    || ink.colorName.localizedCaseInsensitiveContains(text)
            },
            sortOptions: [
                .brand(), .line(), .colorName(), .rating(), .price(), .purchaseDate(),
                .dateAdded(),
            ],
            filterGroups: [.status(), .rating(), .packageType()],
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
