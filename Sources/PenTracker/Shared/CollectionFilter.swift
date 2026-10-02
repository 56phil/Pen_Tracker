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
