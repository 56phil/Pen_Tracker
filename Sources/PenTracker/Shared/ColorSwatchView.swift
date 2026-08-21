import SwiftUI

struct ColorSwatchView: View {
    let hex: String?
    var size: CGFloat = 16

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(hex: hex) ?? Color.secondary.opacity(0.3))
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
    }
}
