import SwiftData
import SwiftUI

struct CollectionListView<
 Model: CollectibleItem, RowContent: View, AddContent: View, DetailContent: View
>: View {
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
 @State private var pushItem: Model?
 @FocusState private var listFocused: Bool

 init(
  items: Binding<[Model]>,
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
  @ViewBuilder detail: @escaping (Model) -> DetailContent
 ) {
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
   (statusFilter == nil || item.status == statusFilter)
    && (searchText.isEmpty || matchesSearch(item, searchText))
  }
 }

 private func delete(_ item: Model) {
  context.delete(item)
  selection.remove(item.id)
  refresh()
 }

 /// Selects the first filtered row and moves keyboard focus into the
 /// list, so arrow keys navigate the rows. Selection here only
 /// highlights: rows are plain buttons, not navigation links, so
 /// selecting never pushes the detail screen.
 private func selectFirstRow() {
  if let first = filteredItems.first {
   selection = [first.id]
  }
  listFocused = true
 }

 private func pushSelected() {
  if let id = selection.first,
   let item = filteredItems.first(where: { $0.id == id })
  {
   pushItem = item
  }
 }

 var body: some View {
  List(selection: $selection) {
   ForEach(filteredItems) { item in
    Button {
     pushItem = item
    } label: {
     row(item)
    }
    .buttonStyle(.plain)
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
  .focused($listFocused)
  .onKeyPress(.return) {
   pushSelected()
   return .handled
  }
  .navigationDestination(item: $pushItem) { item in
   detail(item)
  }
  .navigationTitle(navigationTitle)
  .toolbar {
   ToolbarItem(placement: .automatic) {
    SearchFieldWithTab(text: $searchText, prompt: searchPrompt) {
     selectFirstRow()
    }
    .frame(width: 200)
   }
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
    ContentUnavailableView(
     emptyTitle, systemImage: emptySystemImage,
     description: Text(emptyDescription))
   }
  }
 }
}
