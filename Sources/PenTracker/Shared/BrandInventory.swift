import Foundation

/// A brand as it appears on stored items, with the number of items using it.
///
/// Brands are grouped by their exact stored spelling, so two spellings of one
/// maker — "TWSBI" and "Twsbi" — stay visible as separate entries rather than
/// being silently folded together. Seeing both is what makes the split
/// fixable.
struct BrandEntry: Identifiable, Hashable {
    let name: String
    let count: Int

    var id: String { name }

    /// "3 items", for a row's secondary label.
    var itemCountText: String {
        count == 1 ? "1 item" : "\(count) items"
    }
}

/// The distinct brands across every collection, in the same user-facing text
/// order the lists sort by.
struct BrandInventory {
    let entries: [BrandEntry]

    init(pens: [Pen], inks: [Ink], papers: [Paper]) {
        var counts: [String: Int] = [:]
        for stored in pens.map(\.brand) + inks.map(\.brand) + papers.map(\.brand) {
            let name = stored.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            counts[name, default: 0] += 1
        }
        entries =
            counts
            .map { BrandEntry(name: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                if ascending(lhs.name, rhs.name) { return true }
                if ascending(rhs.name, lhs.name) { return false }
                // Spelled the same but for case: fall back to a byte order so
                // the list does not reshuffle between refreshes.
                return lhs.name < rhs.name
            }
    }

    var isEmpty: Bool { entries.isEmpty }

    func count(of name: String) -> Int {
        entries.first { $0.name == name }?.count ?? 0
    }

    func contains(_ name: String) -> Bool {
        entries.contains { $0.name == name }
    }
}
