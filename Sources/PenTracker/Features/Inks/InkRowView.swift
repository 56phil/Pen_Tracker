import SwiftUI

struct InkRowView: View {
    let ink: Ink

    var body: some View {
        HStack(spacing: 10) {
            ColorSwatchView(hex: ink.colorHex, size: 14)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(ink.brand) \(ink.lineName)")
                Text(ink.colorName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge(status: ink.status)
        }
        .padding(.vertical, 2)
    }
}
