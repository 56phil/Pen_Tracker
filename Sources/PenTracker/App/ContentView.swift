import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $selection) { section in
                Label(section.label, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("PenTracker")
        } detail: {
            NavigationStack {
                switch selection {
                case .dashboard:
                    DashboardView()
                case .pens:
                    PenListView()
                case .inks:
                    InkListView()
                case .papers:
                    PaperListView()
                case .swatches:
                    SwatchGalleryView()
                case nil:
                    Text("Select a section")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
