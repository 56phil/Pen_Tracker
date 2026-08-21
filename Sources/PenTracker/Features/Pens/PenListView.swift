import SwiftUI
import SwiftData

struct PenListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Pen.brand) private var pens: [Pen]

    @State private var searchText = ""
    @State private var statusFilter: CollectionStatus?
    @State private var showingAdd = false

    private var filteredPens: [Pen] {
        pens.filter { pen in
            (statusFilter == nil || pen.status == statusFilter) &&
            (searchText.isEmpty ||
             pen.brand.localizedCaseInsensitiveContains(searchText) ||
             pen.model.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        List {
            ForEach(filteredPens) { pen in
                NavigationLink(value: pen) {
                    PenRowView(pen: pen)
                }
            }
            .onDelete { indexSet in
                for index in indexSet { context.delete(filteredPens[index]) }
            }
        }
        .navigationDestination(for: Pen.self) { pen in
            PenDetailView(pen: pen)
        }
        .searchable(text: $searchText, prompt: "Search pens")
        .navigationTitle("Pens")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("Status", selection: $statusFilter) {
                    Text("All").tag(CollectionStatus?.none)
                    ForEach(CollectionStatus.allCases) { status in
                        Text(status.label).tag(CollectionStatus?.some(status))
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAdd = true
                } label: {
                    Label("Add Pen", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            PenEditView(pen: nil)
        }
        .overlay {
            if pens.isEmpty {
                ContentUnavailableView("No Pens Yet", systemImage: "pencil",
                                        description: Text("Add your first pen to get started."))
            }
        }
    }
}
