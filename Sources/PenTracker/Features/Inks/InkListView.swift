import SwiftUI
import SwiftData

struct InkListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Ink.brand) private var inks: [Ink]

    @State private var searchText = ""
    @State private var statusFilter: CollectionStatus?
    @State private var showingAdd = false

    private var filteredInks: [Ink] {
        inks.filter { ink in
            (statusFilter == nil || ink.status == statusFilter) &&
            (searchText.isEmpty ||
             ink.brand.localizedCaseInsensitiveContains(searchText) ||
             ink.colorName.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        List {
            ForEach(filteredInks) { ink in
                NavigationLink(value: ink) {
                    InkRowView(ink: ink)
                }
            }
            .onDelete { indexSet in
                for index in indexSet { context.delete(filteredInks[index]) }
            }
        }
        .navigationDestination(for: Ink.self) { ink in
            InkDetailView(ink: ink)
        }
        .searchable(text: $searchText, prompt: "Search inks")
        .navigationTitle("Inks")
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
                    Label("Add Ink", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            InkEditView(ink: nil)
        }
        .overlay {
            if inks.isEmpty {
                ContentUnavailableView("No Inks Yet", systemImage: "drop",
                                        description: Text("Add your first ink to get started."))
            }
        }
    }
}
