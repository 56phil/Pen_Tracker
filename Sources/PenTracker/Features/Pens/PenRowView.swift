import SwiftUI

struct PenRowView: View {
    let pen: Pen

    var body: some View {
        HStack(spacing: 10) {
            if let ink = pen.currentInking?.ink {
                ColorSwatchView(hex: ink.colorHex, size: 14)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(pen.brand) \(pen.model)")
                    .font(.body)
                HStack(spacing: 6) {
                    Text(pen.color)
                    Text("·")
                    Text(pen.nibSizeOrTip)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge(status: pen.status)
        }
        .padding(.vertical, 2)
    }
}
