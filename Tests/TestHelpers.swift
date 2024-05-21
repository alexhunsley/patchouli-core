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

extension PatchType where ContentType: AnyObject {
    static func isReferenceType() -> Bool { true }
}

extension PatchType {
    static func isReferenceType() -> Bool { false }
}

//extension PatchedContent where T: PatchType, T.ContentType: Equatable {
extension PatchedContent { // where T.ContentType: Equatable {

    //<T: PatchType>
    func testReducers(expectedContent: T.ContentType, callingFunc: String = #function) throws where T.ContentType: Equatable {

        // non-mutating reduced() func
        let reduced = try reduced()

//        if T.isReferenceType() {
        // expect this for both reference and value types

        // if a content patching op does nothing, it *can* return the same ref here!
            XCTAssertFalse(reduced as AnyObject === content as AnyObject,
                           "Patchable returned something that was referentially equal to start content")
//        }


        XCTAssertEqual(reduced, expectedContent,
                       "Didn't get expected content from reduced() (i.e. non-mutating reducer) in \(callingFunc)")

//        contentCopy.reduce(mutatingPatchable)
//        contentCopy.reduce(T.mutatingPatcher)
//        contentCopy.reduce()

        // mutating reduce() func

        // but what if a class? hmm.
        var patchContentCopy = self
        let originalPatchContentCopy = patchContentCopy
        try patchContentCopy.reduce()

        XCTAssertEqual(patchContentCopy.content, expectedContent,
                       "Didn't get expected content from reduce() (i.e. mutating reducer) in \(callingFunc)")

        if !T.isReferenceType() {
            XCTAssertFalse(patchContentCopy as AnyObject === originalPatchContentCopy as AnyObject,
                           "MutatablePatchable returned something that was referentially unequal to start content")
        }
    }
}
