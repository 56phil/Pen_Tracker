import Combine
import SwiftUI

/// Global menu commands that let keyboard users trigger the same actions as
/// the toolbar buttons. Views register a target while visible; the menu
/// commands dispatch to the most recently registered (topmost) target.
@MainActor
final class CommandCenter: ObservableObject {
    static let shared = CommandCenter()

    @Published private(set) var editCount = 0
    @Published private(set) var inkCount = 0
    @Published private(set) var swatchCount = 0
    @Published private(set) var deleteCount = 0
    @Published private(set) var saveCount = 0
    @Published private(set) var cancelCount = 0
    @Published private(set) var backCount = 0

    private var editTargets: [(id: UUID, action: () -> Void)] = []
    private var inkTargets: [(id: UUID, action: () -> Void)] = []
    private var swatchTargets: [(id: UUID, action: () -> Void)] = []
    private var deleteTargets: [(id: UUID, action: () -> Void)] = []
    private var saveTargets: [(id: UUID, action: () -> Void)] = []
    private var cancelTargets: [(id: UUID, action: () -> Void)] = []
    private var backTargets: [(id: UUID, action: () -> Void)] = []

    var editAvailable: Bool { editCount > 0 }
    var inkAvailable: Bool { inkCount > 0 }
    var swatchAvailable: Bool { swatchCount > 0 }
    var deleteAvailable: Bool { deleteCount > 0 }
    var saveAvailable: Bool { saveCount > 0 }
    var cancelAvailable: Bool { cancelCount > 0 }
    var backAvailable: Bool { backCount > 0 }

    @discardableResult
    func registerEdit(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        editTargets.append((id, action))
        editCount += 1
        return id
    }
    func unregisterEdit(_ id: UUID) {
        editTargets.removeAll { $0.id == id }
        editCount -= 1
    }
    func runEdit() { editTargets.last?.action() }

    @discardableResult
    func registerInk(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        inkTargets.append((id, action))
        inkCount += 1
        return id
    }
    func unregisterInk(_ id: UUID) {
        inkTargets.removeAll { $0.id == id }
        inkCount -= 1
    }
    func runInk() { inkTargets.last?.action() }

    @discardableResult
    func registerSwatch(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        swatchTargets.append((id, action))
        swatchCount += 1
        return id
    }
    func unregisterSwatch(_ id: UUID) {
        swatchTargets.removeAll { $0.id == id }
        swatchCount -= 1
    }
    func runSwatch() { swatchTargets.last?.action() }

    @discardableResult
    func registerDelete(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        deleteTargets.append((id, action))
        deleteCount += 1
        return id
    }
    func unregisterDelete(_ id: UUID) {
        deleteTargets.removeAll { $0.id == id }
        deleteCount -= 1
    }
    func runDelete() { deleteTargets.last?.action() }

    @discardableResult
    func registerSave(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        saveTargets.append((id, action))
        saveCount += 1
        return id
    }
    func unregisterSave(_ id: UUID) {
        saveTargets.removeAll { $0.id == id }
        saveCount -= 1
    }
    func runSave() { saveTargets.last?.action() }

    @discardableResult
    func registerCancel(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        cancelTargets.append((id, action))
        cancelCount += 1
        return id
    }
    func unregisterCancel(_ id: UUID) {
        cancelTargets.removeAll { $0.id == id }
        cancelCount -= 1
    }
    func runCancel() { cancelTargets.last?.action() }

    @discardableResult
    func registerBack(_ action: @escaping () -> Void) -> UUID {
        let id = UUID()
        backTargets.append((id, action))
        backCount += 1
        return id
    }
    func unregisterBack(_ id: UUID) {
        backTargets.removeAll { $0.id == id }
        backCount -= 1
    }
    func runBack() { backTargets.last?.action() }
}
