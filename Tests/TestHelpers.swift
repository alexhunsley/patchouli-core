import Foundation
import XCTest

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

//extension PatchedContent where T: PatchType, T.ContentType: Equatable {
extension PatchedContent { // where T.ContentType: Equatable {

    //<T: PatchType>
    func testReducers(expectedContent: T.ContentType, callingFunc: String = #function) throws where T.ContentType: Equatable {

        // non-mutating reduced() func
        XCTAssertEqual(try reduced(), expectedContent, "Didn't get expected content from reduced() (i.e. non-mutating reducer) in \(callingFunc)")

//        contentCopy.reduce(mutatingPatchable)
//        contentCopy.reduce(T.mutatingPatcher)
//        contentCopy.reduce()

        // mutating reduce() func
        var patchContentCopy = self
        try patchContentCopy.reduce()

        XCTAssertEqual(patchContentCopy.content, expectedContent,
                       "Didn't get expected content from reduce() (i.e. mutating reducer) in \(callingFunc)")
    }
}
