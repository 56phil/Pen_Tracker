import SwiftUI

extension Color {
    init?(hex: String?) {
        guard var hex = hex?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        hex = hex.replacingOccurrences(of: "#", with: "")

        let rgba: String
        switch hex.count {
        case 3: // RGB shorthand, e.g. "FA0" -> "FFAA00"
            rgba = hex.map { "\($0)\($0)" }.joined() + "FF"
        case 6: // RRGGBB
            rgba = hex + "FF"
        case 8: // RRGGBBAA
            rgba = hex
        default:
            return nil
        }

        guard let value = UInt64(rgba, radix: 16) else { return nil }
        let r = Double((value >> 24) & 0xFF) / 255
        let g = Double((value >> 16) & 0xFF) / 255
        let b = Double((value >> 8) & 0xFF) / 255
        let a = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
