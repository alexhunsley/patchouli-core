import Foundation
import XCTest

@testable import PatchouliCore

extension PatchType {
    static public func testingPatcher(nilAddedFunc: Bool = false,
                                      nilRemovedFunc: Bool = false,
                                      nilReplacedFunc: Bool = false,
                                      nilCopiedFunc: Bool = false,
                                      nilMovedFunc: Bool = false,
                                      nilTestFunc: Bool = false) -> Patchable<Self> {
        Patchable(added: nilAddedFunc ? nil : patcher.added,
                  removed: nilRemovedFunc ? nil : patcher.removed,
                  replaced: nilReplacedFunc ? nil : patcher.replaced,
                  copied: nilCopiedFunc ? nil : patcher.copied,
                  moved: nilMovedFunc ? nil : patcher.moved,
                  test: nilTestFunc ? nil : patcher.test
        )
    }
}

// not currently used!
extension PatchType where ContentType: AnyObject {
    static func isReferenceType() -> Bool { true }
}

extension PatchType {
    static func isReferenceType() -> Bool { false }
}

//extension PatchedContent where T: PatchType, T.ContentType: Equatable {
extension PatchedContent { // where T.ContentType: Equatable {


    /// Tests both reduced and reduce
//    mutating
    func testReducers(expectedContent: T.ContentType, callingFunc: String = #function) throws where T.ContentType: Equatable {

        // non-mutating reduced() func
        let reduced = try reduced()

        // expect this for both reference and value types

        // if a content patching op does nothing, it *can* return the same ref here!
        // -- yes, this fails if used for string.

        // hmm exact form?
//        if !T.ContentType.isReferenceType() {
//            XCTAssertFalse(reduced as AnyObject === content as AnyObject,
//                           "Patchable returned something that was referentially equal to start content")
//        }


        XCTAssertEqual(reduced, expectedContent,
                       "Didn't get expected content from reduced() (i.e. non-mutating reducer) in \(callingFunc)")

//        contentCopy.reduce(mutatingPatchable)
//        contentCopy.reduce(T.mutatingPatcher)
//        contentCopy.reduce()

        // mutating reduce() func

        // but what if a class? hmm.

        // we make a copy here so we don't have to mark this method as mutating
        var mutableContentCopy = self
        try mutableContentCopy.reduce()
//        try reduce()

        // "prestidigitation") is not equal to ("prestiFOOdigitation")
        XCTAssertEqual(mutableContentCopy.content, expectedContent,
                       "Didn't get expected content from reduce() (i.e. mutating reducer) in \(callingFunc)")

        // hmm exact form?
//        if !T.ContentType.isReferenceType() {
//            XCTAssertFalse(patchContentCopy as AnyObject === originalPatchContentCopy as AnyObject,
//                           "MutatablePatchable returned something that was referentially unequal to start content")
//        }
    }

    func assertReducersDoNotThrow() {
        var mutableCopy = self
        XCTAssertNoThrow(try mutableCopy.reduced())
        XCTAssertNoThrow(try mutableCopy.reduce())
    }
}
