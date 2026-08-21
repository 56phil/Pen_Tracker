import Foundation
import SwiftData

protocol CollectibleItem: PersistentModel {
    var brand: String { get }
    var status: CollectionStatus { get }
}

extension Pen: CollectibleItem {}
extension Ink: CollectibleItem {}
extension Paper: CollectibleItem {}
