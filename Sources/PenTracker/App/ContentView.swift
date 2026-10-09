import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarSection? = .dashboard
    @State private var path: NavigationPath = NavigationPath()
    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $selection) { section in
                Label(section.label, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("PenTracker")
        } detail: {
            NavigationStack(path: $path) {
                switch selection {
                case .dashboard:
                    DashboardView()
                case .pens:
                    PenListView(path: $path)
                case .inks:
                    InkListView(path: $path)
                case .papers:
                    PaperListView(path: $path)
                case .swatches:
                    SwatchGalleryView(path: $path)
                case nil:
                    Text("Select a section")
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: selection) { _, _ in
                path = NavigationPath()
            }
        }
    }
}
