import SwiftUI
import SwiftData

struct SwatchGalleryView: View {
    @Query(sort: \Swatch.dateTested, order: .reverse) private var swatches: [Swatch]
    @Environment(\.modelContext) private var context

    @State private var showingAdd = false

    private let columns = [GridItem(.adaptive(minimum: 220), spacing: 16)]

    var body: some View {
        ScrollView {
            if swatches.isEmpty {
                ContentUnavailableView("No Swatches Yet", systemImage: "paintpalette",
                                        description: Text("Test an ink on a paper to build your swatch gallery."))
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(swatches) { swatch in
                        NavigationLink(value: swatch) {
                            VStack(alignment: .leading, spacing: 8) {
                                if let ink = swatch.ink {
                                    HStack {
                                        ColorSwatchView(hex: ink.colorHex, size: 24)
                                        Text("\(ink.brand) \(ink.colorName)")
                                            .fontWeight(.medium)
                                    }
                                }
                                if let paper = swatch.paper {
                                    Text("\(paper.brand) \(paper.lineName)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                RatingDisplayView(rating: swatch.rating)
                                Text(swatch.dateTested.abbreviated)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.quaternary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                context.delete(swatch)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationDestination(for: Swatch.self) { swatch in
            SwatchDetailView(swatch: swatch)
        }
        .navigationTitle("Swatches")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAdd = true
                } label: {
                    Label("Add Swatch", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            SwatchEditSheet(presetInk: nil, presetPaper: nil)
        }
    }
}
