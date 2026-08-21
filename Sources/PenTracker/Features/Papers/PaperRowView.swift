import SwiftUI

struct PaperRowView: View {
    let paper: Paper

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(paper.brand) \(paper.lineName)")
                HStack(spacing: 6) {
                    Text(paper.format)
                    if let gsm = paper.weightGSM {
                        Text("· \(gsm) gsm")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge(status: paper.status)
        }
        .padding(.vertical, 2)
    }
}
