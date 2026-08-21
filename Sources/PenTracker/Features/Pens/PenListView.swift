import SwiftUI

struct PenListView: View {
    var body: some View {
        CollectionListView<Pen, PenRowView, PenEditView, PenDetailView>(
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
    }
}
