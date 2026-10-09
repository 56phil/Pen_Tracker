import Foundation

/// One selectable value in a filter group. A group's first option is its
/// default and conventionally means "no filtering", so its `matches` always
/// returns true.
struct CollectionFilterOption<Model>: Identifiable {
 let id: String
 let label: String
 let matches: (_ item: Model) -> Bool
}

/// A named set of mutually exclusive filter options, presented as one
/// submenu of the list's Filter toolbar control.
struct CollectionFilterGroup<Model>: Identifiable {
 let id: String
 let label: String
 let options: [CollectionFilterOption<Model>]
}

extension CollectionFilterGroup where Model: CollectibleItem {
 /// Collection status: wishlist, in rotation, stored, retired.
 static func status() -> Self {
  let all = CollectionFilterOption<Model>(id: "all", label: "All") { _ in true }
  let statuses = CollectionStatus.allCases.map { status in
   CollectionFilterOption<Model>(id: status.rawValue, label: status.label) { item in
    item.status == status
   }
  }
  return Self(id: "status", label: "Status", options: [all] + statuses)
 }

 /// Four-level rating, with unrated items as their own option.
 static func rating() -> Self {
  let any = CollectionFilterOption<Model>(id: "any", label: "Any") { _ in true }
  let rated = ItemRating.allCases.map { rating in
   CollectionFilterOption<Model>(id: "rating-\(rating.rawValue)", label: rating.label) { item in
    item.rating == rating
   }
  }
  let unrated = CollectionFilterOption<Model>(id: "unrated", label: "Unrated") { item in
   item.rating == nil
  }
  return Self(id: "rating", label: "Rating", options: [any] + rated + [unrated])
 }
}

extension CollectionFilterGroup where Model == Pen {
 /// Nib / tip, one option per exact stored value. Nib strings are free text,
 /// so the options follow the data rather than a fixed scale: a pen listed as
 /// "<F>" and one listed as "Fine" are separate options, and no shorthand is
 /// silently folded into another.
 static func nib(_ pens: [Pen]) -> Self {
  let all = CollectionFilterOption<Pen>(id: "all", label: "All") { _ in true }
  let nibs = valueCounts(pens.map(\.nibSizeOrTip)).map { value, count in
   CollectionFilterOption<Pen>(id: "nib-\(value)", label: label(value, count)) { pen in
    pen.nibSizeOrTip == value
   }
  }
  return Self(id: "nib", label: "Nib", options: [all] + nibs)
 }

 /// Filling mechanism, one option per exact stored value, for the same
 /// reason as `nib(_:)` — the values are typed by hand, so near-duplicates
 /// such as "Vaccume" and "Vaccume " stay separate options. Their counts
 /// differ, which is the only way to tell those two look-alike rows apart.
 static func fillingMechanism(_ pens: [Pen]) -> Self {
  let all = CollectionFilterOption<Pen>(id: "all", label: "All") { _ in true }
  let mechanisms = valueCounts(pens.map(\.fillingMechanism)).map { value, count in
   CollectionFilterOption<Pen>(
    id: "filling-\(value)", label: label(value, count)
   ) { pen in
    pen.fillingMechanism == value
   }
  }
  return Self(id: "filling", label: "Filling", options: [all] + mechanisms)
 }

 /// Distinct stored values with how many pens use each, blank values dropped
 /// and the rest in the same user-facing order the lists sort by.
 private static func valueCounts(_ values: [String]) -> [(String, Int)] {
  var counts: [String: Int] = [:]
  for value in values {
   guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
   counts[value, default: 0] += 1
  }
  return
   counts
   .map { ($0.key, $0.value) }
   .sorted { ascending($0.0, $1.0) }
 }

 /// "Fine (7)". The count is not decoration: two values differing only in
 /// trailing whitespace would otherwise render as identical rows.
 private static func label(_ value: String, _ count: Int) -> String {
  "\(value) (\(count))"
 }
}

extension CollectionFilterGroup where Model == Ink {
 /// Ink packaging: bottle, sample, or cartridge.
 static func packageType() -> Self {
  let any = CollectionFilterOption<Ink>(id: "any", label: "Any") { _ in true }
  let types = InkPackageType.allCases.map { type in
   CollectionFilterOption<Ink>(id: type.rawValue, label: type.label) { ink in
    ink.packageType == type
   }
  }
  return Self(id: "package", label: "Package", options: [any] + types)
 }
}
