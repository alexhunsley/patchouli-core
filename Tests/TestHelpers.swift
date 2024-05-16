import Foundation

@testable import PatchouliCore

extension PatchType {
    static public func testingPatcher(nilReplacedFunc: Bool = false,
                                        nilMovedFunc: Bool = false,
                                        nilDeletedFunc: Bool = false,
                                        nilAddedFunc: Bool = false) -> Patchable<Self> {
        Patchable(added: nilAddedFunc ? nil : patcher.added,
                  replaced: nilReplacedFunc ? nil : patcher.replaced,
                  moved: nilMovedFunc ? nil : patcher.moved,
                  deleted: nilDeletedFunc ? nil : patcher.deleted)
    }
}
