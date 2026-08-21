import SwiftUI
import SwiftData

struct CurrentlyInkedView: View {
    @Query(sort: \Pen.brand) private var pens: [Pen]

    private let columns = [GridItem(.adaptive(minimum: 240), spacing: 16)]

    private var inkedPens: [Pen] {
        pens.filter { $0.currentInking != nil }
    }

    var body: some View {
        ScrollView {
            if inkedPens.isEmpty {
                ContentUnavailableView("No Pens Currently Inked", systemImage: "pencil.slash",
                                        description: Text("Ink a pen from its detail view to see it here."))
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(inkedPens) { pen in
                        if let inking = pen.currentInking, let ink = inking.ink {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    ColorSwatchView(hex: ink.colorHex, size: 20)
                                    VStack(alignment: .leading) {
                                        Text("\(pen.brand) \(pen.model)").fontWeight(.medium)
                                        Text("\(ink.brand) \(ink.colorName)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                Text("Filled \(inking.filledDate.abbreviated)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Button("Empty") {
                                    inking.emptiedDate = .now
                                }
                                .font(.caption)
                            }
                            .padding()
                            .background(.quaternary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Dashboard")
    }
}
