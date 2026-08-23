import SwiftUI
import SwiftData

struct PenListView: View {
    @Environment(\.modelContext) private var context
    @State private var pens: [Pen] = []

    var body: some View {
        CollectionListView<Pen, PenRowView, PenEditView, PenDetailView>(
            items: $pens,
            refresh: fetchPens,
            navigationTitle: "Pens",
            searchPrompt: "Search pens",
            addLabel: "Add Pen",
            emptyTitle: "No Pens Yet",
            emptySystemImage: "pencil",
            emptyDescription: "Add your first pen to get started.",
            matchesSearch: { pen, text in
                pen.brand.localizedCaseInsensitiveContains(text) ||
                pen.model.localizedCaseInsensitiveContains(text)
            },
            row: { pen in PenRowView(pen: pen) },
            addSheet: { PenEditView(pen: nil) },
            detail: { pen in PenDetailView(pen: pen) }
        )
        .onAppear(perform: fetchPens)
    }

    private func fetchPens() {
        let descriptor = FetchDescriptor<Pen>(sortBy: [SortDescriptor(\.brand)])
        pens = (try? context.fetch(descriptor)) ?? []
    }
}
