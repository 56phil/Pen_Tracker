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

    /// Orderings offered in the Sort toolbar menu; the first is the default.
    let sortOptions: [CollectionSort<Model>]
    /// Filter groups offered in the Filter toolbar menu, each rendered as a
    /// submenu of mutually exclusive options.
    let filterGroups: [CollectionFilterGroup<Model>]

    @ViewBuilder let row: (Model) -> RowContent
    @ViewBuilder let addSheet: () -> AddContent
    @ViewBuilder let detail: (Model) -> DetailContent

    @State private var searchText = ""
    @State private var sortID: String
    @State private var sortAscending = true
    @State private var filterChoice: [String: String] = [:]
    @State private var showingAdd = false
    @State private var selection: Set<Model.ID> = []
    @Binding var path: NavigationPath
    @FocusState private var listFocused: Bool

    init(
        path: Binding<NavigationPath>,
        items: Binding<[Model]>,
        refresh: @escaping () -> Void,
        navigationTitle: String,
        searchPrompt: String,
        addLabel: String,
        emptyTitle: String,
        emptySystemImage: String,
        emptyDescription: String,
        matchesSearch: @escaping (Model, String) -> Bool,
        sortOptions: [CollectionSort<Model>],
        filterGroups: [CollectionFilterGroup<Model>] = [],
        @ViewBuilder row: @escaping (Model) -> RowContent,
        @ViewBuilder addSheet: @escaping () -> AddContent,
        @ViewBuilder detail: @escaping (Model) -> DetailContent
    ) {
        _path = path
        _items = items
        self.refresh = refresh
        self.navigationTitle = navigationTitle
        self.searchPrompt = searchPrompt
        self.addLabel = addLabel
        self.emptyTitle = emptyTitle
        self.emptySystemImage = emptySystemImage
        self.emptyDescription = emptyDescription
        self.matchesSearch = matchesSearch
        self.sortOptions = sortOptions
        self.filterGroups = filterGroups
        self.row = row
        self.addSheet = addSheet
        self.detail = detail
        _sortID = State(initialValue: sortOptions.first?.id ?? "")
    }

    private var visibleItems: [Model] {
        let matching = items.filter { item in
            (searchText.isEmpty || matchesSearch(item, searchText))
                && filterGroups.allSatisfy { matches($0, item) }
        }
        guard let sort = sortOptions.first(where: { $0.id == sortID }) ?? sortOptions.first
        else { return matching }
        return matching.sorted { lhs, rhs in
            sortAscending ? sort.compare(lhs, rhs) : sort.compare(rhs, lhs)
        }
    }

    /// Whether an item passes the option currently chosen in `group`. A group
    /// with nothing chosen falls back to its first option, which means "all".
    private func matches(_ group: CollectionFilterGroup<Model>, _ item: Model) -> Bool {
        guard let option = group.options.first(where: { $0.id == selectedOptionID(group) })
        else { return true }
        return option.matches(item)
    }

    private func selectedOptionID(_ group: CollectionFilterGroup<Model>) -> String {
        filterChoice[group.id] ?? group.options.first?.id ?? ""
    }

    /// A group is off its default option, i.e. it is narrowing the list.
    private func isFiltering(_ group: CollectionFilterGroup<Model>) -> Bool {
        guard let defaultID = group.options.first?.id else { return false }
        return filterChoice[group.id].map { $0 != defaultID } ?? false
    }

    private var isFiltering: Bool { filterGroups.contains(where: isFiltering) }

    private func delete(_ item: Model) {
        context.delete(item)
        selection.remove(item.id)
        refresh()
    }

    /// Selects the first visible row and moves keyboard focus into the
    /// list, so arrow keys navigate the rows. Selection here only
    /// highlights: a double-click (or Return) is what pushes the detail
    /// screen, so single-clicking a row never navigates.
    private func selectFirstRow() {
        if let first = visibleItems.first {
            selection = [first.id]
        }
        listFocused = true
    }

    private func pushSelected() {
        if let id = selection.first,
            let item = visibleItems.first(where: { $0.id == id })
        {
            path.append(item)
        }
    }

    /// Pops the detail pushed for this section's path, restoring the list.
    /// A shared, section-scoped path is emptied on every section change, so at
    /// most one detail is ever shown and a sidebar click always returns to the
    /// list.
    private func popToRoot() {
        path.removeLast(path.count)
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(visibleItems) { item in
                row(item)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        path.append(item)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            delete(item)
                        }
                    }
            }
            .onDelete { indexSet in
                for index in indexSet { context.delete(visibleItems[index]) }
                refresh()
            }
        }
        .focused($listFocused)
        .onKeyPress(.return) {
            pushSelected()
            return .handled
        }
        .navigationDestination(for: Model.self) { item in
            detail(item)
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            if !path.isEmpty {
                ToolbarItem(placement: .navigation) {
                    BackBarButton { popToRoot() }
                }
            }
            ToolbarItem(placement: .automatic) {
                SearchFieldWithTab(text: $searchText, prompt: searchPrompt) {
                    selectFirstRow()
                }
                .frame(width: 200)
            }
            ToolbarItem(placement: .automatic) {
                sortMenu
            }
            if !filterGroups.isEmpty {
                ToolbarItem(placement: .automatic) {
                    filterMenu
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
            } else if visibleItems.isEmpty {
                ContentUnavailableView(
                    "No Matches", systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("No items match the current search and filters."))
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Section("Sort By") {
                ForEach(sortOptions) { option in
                    Button {
                        if sortID == option.id {
                            sortAscending.toggle()
                        } else {
                            sortID = option.id
                            sortAscending = true
                        }
                    } label: {
                        if option.id == sortID {
                            Label(
                                option.label, systemImage: sortAscending ? "arrow.up" : "arrow.down"
                            )
                        } else {
                            Text(option.label)
                        }
                    }
                }
            }
            Section("Direction") {
                Button {
                    sortAscending = true
                } label: {
                    checkmarked("Ascending", when: sortAscending)
                }
                Button {
                    sortAscending = false
                } label: {
                    checkmarked("Descending", when: !sortAscending)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .help("Sort")
    }

    private var filterMenu: some View {
        Menu {
            ForEach(filterGroups) { group in
                Menu(group.label) {
                    ForEach(group.options) { option in
                        Button {
                            filterChoice[group.id] = option.id
                        } label: {
                            checkmarked(option.label, when: selectedOptionID(group) == option.id)
                        }
                    }
                }
            }
            if isFiltering {
                Divider()
                Button("Clear Filters") {
                    filterChoice = [:]
                }
            }
        } label: {
            Label(
                "Filter",
                systemImage: isFiltering
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle")
        }
        .help("Filter")
    }

    @ViewBuilder
    private func checkmarked(_ label: String, when checked: Bool) -> some View {
        if checked {
            Label(label, systemImage: "checkmark")
        } else {
            Text(label)
        }
    }
}
