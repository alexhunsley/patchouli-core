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

extension PatchedContent {

    /// Tests both reduced and reduce
    func testReducers(expectedContent: T.ContentType, callingFunc: String = #function) throws where T.ContentType: Equatable {

        // non-mutating reduced() func
        let reduced = try reduced()

        XCTAssertEqual(reduced, expectedContent,
                       "Didn't get expected content from reduced() (i.e. non-mutating reducer) in \(callingFunc)")
    }

    func assertReducersDoNotThrow() {
        var mutableCopy = self
        XCTAssertNoThrow(try mutableCopy.reduced())
    }
}

public struct DummyPatchType: PatchType {
    public typealias ContentType = Once
    public typealias AddressType = Never

    public static var emptyContent: ContentType { Once.once }

    // The dummy patcher provides no patching functions
    public static var patcher = Patchable<DummyPatchType>()
    public static var mutatingPatcher = MutatingPatchable<DummyPatchType>()
}
