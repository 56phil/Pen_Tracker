import SwiftUI
import SwiftData

struct CollectionListView<Model: CollectibleItem, RowContent: View, AddContent: View, DetailContent: View>: View {
    @Environment(\.modelContext) private var context
    @Binding var items: [Model]
    let refresh: () -> Void

    let navigationTitle: String
    let searchPrompt: String
    let addLabel: String
    let emptyTitle: String
    let emptySystemImage: String
    let emptyDescription: String
    let matchesSearch: (Model, String) -> Bool

    @ViewBuilder let row: (Model) -> RowContent
    @ViewBuilder let addSheet: () -> AddContent
    @ViewBuilder let detail: (Model) -> DetailContent

    @State private var searchText = ""
    @State private var statusFilter: CollectionStatus?
    @State private var showingAdd = false
    @State private var selection: Set<Model.ID> = []

    init(items: Binding<[Model]>,
         refresh: @escaping () -> Void,
         navigationTitle: String,
         searchPrompt: String,
         addLabel: String,
         emptyTitle: String,
         emptySystemImage: String,
         emptyDescription: String,
         matchesSearch: @escaping (Model, String) -> Bool,
         @ViewBuilder row: @escaping (Model) -> RowContent,
         @ViewBuilder addSheet: @escaping () -> AddContent,
         @ViewBuilder detail: @escaping (Model) -> DetailContent) {
        _items = items
        self.refresh = refresh
        self.navigationTitle = navigationTitle
        self.searchPrompt = searchPrompt
        self.addLabel = addLabel
        self.emptyTitle = emptyTitle
        self.emptySystemImage = emptySystemImage
        self.emptyDescription = emptyDescription
        self.matchesSearch = matchesSearch
        self.row = row
        self.addSheet = addSheet
        self.detail = detail
    }

    private var filteredItems: [Model] {
        items.filter { item in
            (statusFilter == nil || item.status == statusFilter) &&
            (searchText.isEmpty || matchesSearch(item, searchText))
        }
    }

    private func delete(_ item: Model) {
        context.delete(item)
        selection.remove(item.id)
        refresh()
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredItems) { item in
                NavigationLink(value: item) {
                    row(item)
                }
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        delete(item)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet { context.delete(filteredItems[index]) }
                refresh()
            }
        }
        .navigationDestination(for: Model.self) { item in
            detail(item)
        }
        .searchable(text: $searchText, prompt: searchPrompt)
        .navigationTitle(navigationTitle)
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
                    Label(addLabel, systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd, onDismiss: refresh) {
            addSheet()
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView(emptyTitle, systemImage: emptySystemImage,
                                        description: Text(emptyDescription))
            }
        }
    }
}
