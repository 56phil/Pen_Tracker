import Foundation

/// A named ordering for a collection list. `compare` is a strict weak
/// ordering that sorts ascending; the list reverses its arguments to sort
/// descending. The first sort option a list supplies is its default.
struct CollectionSort<Model>: Identifiable {
 let id: String
 let label: String
 let compare: (_ lhs: Model, _ rhs: Model) -> Bool
}

/// Ascending comparison for user-facing text, so "Ink 2" precedes "Ink 10"
/// and case or accents do not reshuffle the order.
private func ascending(_ lhs: String, _ rhs: String) -> Bool {
 lhs.localizedStandardCompare(rhs) == .orderedAscending
}

/// Ascending comparison that keeps `nil` after every value, so unrated,
/// unpriced, or undated items collect at the bottom of an ascending list.
private func ascending<T: Comparable>(_ lhs: T?, _ rhs: T?) -> Bool {
 switch (lhs, rhs) {
 case (let lhs?, let rhs?): return lhs < rhs
 case (nil, _?): return false
 case (_?, nil): return true
 default: return false
 }
}

/// Orders by `lhs`/`rhs` when they differ, otherwise by `tieBreak`, so equal
/// items keep a deterministic order across refreshes.
private func ordered(_ lhs: String, _ rhs: String, tieBreak: Bool) -> Bool {
 if ascending(lhs, rhs) { return true }
 if ascending(rhs, lhs) { return false }
 return tieBreak
}

private func ordered<T: Comparable>(_ lhs: T?, _ rhs: T?, tieBreak: Bool) -> Bool {
 if ascending(lhs, rhs) { return true }
 if ascending(rhs, lhs) { return false }
 return tieBreak
}

extension CollectionSort where Model: CollectibleItem {
 /// Brand, then the order items were added.
 static func brand() -> Self {
  Self(id: "brand", label: "Brand") { lhs, rhs in
   ordered(lhs.brand, rhs.brand, tieBreak: ascending(lhs.createdAt, rhs.createdAt))
  }
 }

 /// Rating from outstanding down to unsatisfactory, then brand.
 static func rating() -> Self {
  Self(id: "rating", label: "Rating") { lhs, rhs in
   ordered(
    lhs.rating?.rawValue, rhs.rating?.rawValue,
    tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }

 /// Purchase date, oldest first, then brand.
 static func purchaseDate() -> Self {
  Self(id: "purchaseDate", label: "Purchase Date") { lhs, rhs in
   ordered(lhs.purchaseDate, rhs.purchaseDate, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }

 /// Price, cheapest first, then brand.
 static func price() -> Self {
  Self(id: "price", label: "Price") { lhs, rhs in
   ordered(lhs.price, rhs.price, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }

 /// When the item was added to the collection, oldest first.
 static func dateAdded() -> Self {
  Self(id: "dateAdded", label: "Date Added") { lhs, rhs in
   ordered(lhs.createdAt, rhs.createdAt, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }
}

extension CollectionSort where Model == Pen {
 /// Brand and model together as one key, then the order the pens were
 /// added. Concatenating the model keeps every pen of the same model
 /// adjacent and orders V126 ahead of V200, matching what the row shows.
 static func brand() -> Self {
  Self(id: "brand", label: "Brand") { lhs, rhs in
   ordered(
    "\(lhs.brand) \(lhs.model)", "\(rhs.brand) \(rhs.model)",
    tieBreak: ascending(lhs.createdAt, rhs.createdAt))
  }
 }

 /// Pen model name, then brand.
 static func model() -> Self {
  Self(id: "model", label: "Model") { lhs, rhs in
   ordered(lhs.model, rhs.model, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }
}

extension CollectionSort where Model == Ink {
 /// Ink line name, then brand.
 static func line() -> Self {
  Self(id: "line", label: "Line") { lhs, rhs in
   ordered(lhs.lineName, rhs.lineName, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }

 /// Ink color name, then brand.
 static func colorName() -> Self {
  Self(id: "colorName", label: "Color") { lhs, rhs in
   ordered(lhs.colorName, rhs.colorName, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }
}

extension CollectionSort where Model == Paper {
 /// Paper line name, then brand.
 static func line() -> Self {
  Self(id: "line", label: "Line") { lhs, rhs in
   ordered(lhs.lineName, rhs.lineName, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }

 /// Paper weight, lightest first; paper with no weight listed sorts last.
 static func weight() -> Self {
  Self(id: "weight", label: "Weight") { lhs, rhs in
   ordered(lhs.weightGSM, rhs.weightGSM, tieBreak: ascending(lhs.brand, rhs.brand))
  }
 }
}
