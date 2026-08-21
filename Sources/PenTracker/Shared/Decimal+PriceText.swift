import Foundation

extension Decimal {
    /// Parses a decimal typed into a plain text field using the current locale's
    /// number conventions (e.g. "12,50" in fr_FR), rather than requiring a literal ".".
    init?(priceText: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        guard let number = formatter.number(from: priceText) else { return nil }
        self = number.decimalValue
    }

    /// Formats for round-tripping back into that same text field.
    var priceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
}
