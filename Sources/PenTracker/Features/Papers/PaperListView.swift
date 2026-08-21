import SwiftUI
import SwiftData

struct PaperListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Paper.brand) private var papers: [Paper]

    @State private var searchText = ""
    @State private var statusFilter: CollectionStatus?
    @State private var showingAdd = false

    private var filteredPapers: [Paper] {
        papers.filter { paper in
            (statusFilter == nil || paper.status == statusFilter) &&
            (searchText.isEmpty ||
             paper.brand.localizedCaseInsensitiveContains(searchText) ||
             paper.lineName.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        List {
            ForEach(filteredPapers) { paper in
                NavigationLink(value: paper) {
                    PaperRowView(paper: paper)
                }
            }
            .onDelete { indexSet in
                for index in indexSet { context.delete(filteredPapers[index]) }
            }
        }
        .navigationDestination(for: Paper.self) { paper in
            PaperDetailView(paper: paper)
        }
        .searchable(text: $searchText, prompt: "Search paper")
        .navigationTitle("Paper")
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
                    Label("Add Paper", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            PaperEditView(paper: nil)
        }
        .overlay {
            if papers.isEmpty {
                ContentUnavailableView("No Paper Yet", systemImage: "doc.plaintext",
                                        description: Text("Add your first paper to get started."))
            }
        }
    }
}
