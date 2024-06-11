import XCTest

@testable import PatchouliCore

final class PatchouliCoreTests: XCTestCase {

    // MARK: - generic patch spec instantiation (DSL)

    // MARK: - Empty

    func test_emptyPatchListProducesEmptyList() throws {
        let emptyPatchedContentList: [AddressedPatch<DummyPatchType>] = AddressedPatch.emptyPatchList
        XCTAssertEqual(emptyPatchedContentList.count, 0, "Unexpected number of items in patch list")
    }

    func test_DSL_ContentWithNoChildrenMakesEmptyPatchList() throws {
        let patchList: PatchedString = Content("")
        XCTAssertEqual(patchList.contentPatches.count, 0, "Unexpected number of items in patch list")
    }

    // MARK: - Optional

    func test_DSL_optionalPatchItemWhenNil() throws {
        let nilOptionalPatch: StringPatchItem? = nil

        let patchedContent: PatchedString = Content("one") {
            nilOptionalPatch
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 0,
                       "Expected to find no patches in list, but found \(patchedContent.contentPatches)")
    }

    func test_DSL_optionalPatchItemWhenNonNil() throws {
        let nonNilOptionalPatch: StringPatchItem? = Replace(address: "tues", with: "weds")

        let patchedContent: PatchedString = Content("one") {
            nonNilOptionalPatch
        }

        let patchSpec = patchedContent.contentPatches[0].patchSpec

        switch patchSpec {
        case .replace:
            break
        default:
            XCTFail("Expected .replace for patchSpec at 0, instead found \(patchSpec)")
        }
    }

    // MARK: - Data retrieval

    func test_DSL_ContentDataCanBeRetrieved() throws {
        let patchedContent: PatchedString = Content("one")
        XCTAssertEqual(patchedContent.content, "one", "Unexpected content found")
    }

    // MARK: - Patch list item retrieval

    func test_DSL_ContentWithEmptyPatchListMakesEmptyPatchList() throws {
        let patchedContent: PatchedString = Content("one") { }
        XCTAssertEqual(patchedContent.contentPatches.count, 0, "Unexpected number of items in patch list")
    }

    func test_DSL_ContentWithOnePatchMakesPatchListWithOneItem() throws {
        let patchedContent: PatchedString = Content("one") {
            Replace(address: "tues", with: "weds")
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 1, "Unexpected number of items in patch list")
    }

    func test_DSL_ContentWithThreePatchesMakesPatchListWithThreeItem() throws {
        let patchedContent: PatchedString = Content("one two three four") {
            Replace(address: "one", with: "X")
            Replace(address: "two", with: "Y")
            Replace(address: "three", with: "Z")
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 3, "Unexpected number of items in patch list")
    }

    // MARK: - Loops and For

    func test_DSL_forLoopWorks() throws {
        let patch: [StringPatchItem] = [
            Replace(address: "one", with: "two"),
            Replace(address: "two", with: "three"),
            Replace(address: "three", with: "four"),
        ]

        let patchedContent: PatchedString = Content("one") {
            for index in 0...2 {
                patch[index]
            }
            Replace(address: "three", with: "four")
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 4, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "four")
    }

    func test_DSL_forInWorks() throws {
        let patches: [StringPatchItem] = [
            Replace(address: "one", with: "two"),
            Replace(address: "two", with: "three"),
            Replace(address: "three", with: "four"),
        ]

        let patchedContent: PatchedString = Content("one") {
            // i have disabled build array for now
            for patch in patches {
                patch
            }
            patches[1]
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 4, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "four")
    }

    // MARK: - If

    func test_DSL_ifTrueWorks() throws {
        let patch_two: StringPatchItem = Replace(address: "one", with: "two")
        let patch_three: StringPatchItem = Replace(address: "one", with: "three")
        let trueCondition = true

        let patchedContent: PatchedString = Content("one") {
            if trueCondition {
                patch_two
            }
            patch_three
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "two")
    }

    func test_DSL_ifFalseWorks() throws {
        let patch_two: StringPatchItem = Replace(address: "one", with: "two")
        let patch_three: StringPatchItem = Replace(address: "one", with: "three")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            if falseCondition {
                patch_two
            }
            patch_three
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 1, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "three")
    }

    func test_DSL_ifElseTrueWorks() throws {
        let patch: StringPatchItem = Replace(address: "one", with: "two")
        let otherPatch: StringPatchItem = Replace(address: "one", with: "horse")

        let falseCondition = true

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "tree", with: "horse")

            if falseCondition {
                patch
            }
            else {
                otherPatch
            }
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "two")
    }

    func test_DSL_ifElseFalseWorks() throws {
        let patch: StringPatchItem = Replace(address: "one", with: "two")
        let otherPatch: StringPatchItem = Replace(address: "one", with: "horse")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            if falseCondition {
                otherPatch
            }
            else {
                patch
            }
            Replace(address: "tree", with: "horse")
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "two")
    }

    func test_DSL_ifElseFalseContainingPatchedContentWorks() throws {
        let patch: StringPatchItem = Replace(address: "one", withContent: Content("two") {
            Replace(address: "two", with: "three")
        })

        let otherPatch: StringPatchItem = Replace(address: "one", with: "horse")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "tree", with: "horse")

            if falseCondition {
                otherPatch
            }
            else {
                patch
            }
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "three")
    }

    func test_DSL_ifElseFalseContainingOptionalPatchedContentWorks() throws {
        let patch: StringPatchItem? = Replace(address: "one", withContent: Content("two") {
            Replace(address: "two", with: "three")
        })

        let otherPatch: StringPatchItem? = Replace(address: "one", with: "horse")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            if falseCondition {
                otherPatch
            }
            else {
                patch
            }
            Replace(address: "tree", with: "horse")
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "three")
    }

    func test_DSL_siblingIfsWorks() throws {
        let patch: StringPatchItem? = Replace(address: "one", with: "two")
        let patch2: StringPatchItem = Replace(address: "two", with: "three")
        let trueCondition = true

        let patchedContent: PatchedString = Content("one") {
            if trueCondition {
                // Cannot pass array of type '[StringPatch]' as variadic arguments of type 'StringPatch'
                patch
            }

            if trueCondition {
                patch2
            }

            patch
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 3, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "three")
    }

    // MARK: - Patches

    func test_DSL_patchWithSimpleDataAndNoPatchListCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Replace(address: "one", with: "X")

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 0, "Expected to find 0 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndEmptyPatchListCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Replace(address: "one", with: "X") {
            // nothing
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 0, "Expected to find 0 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndPatchListOfOneItemCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Replace(address: "one", with: "X") {
            Replace(address: "two", with: "Y")
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 1, "Expected to find 1 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndPatchListOfTwoItemsCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Replace(address: "one", with: "X") {
            Replace(address: "two", with: "Y")
            Replace(address: "three", with: "Z")
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 2, "Expected to find 1 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndNestedPatchListOfOneItemTwoItemsCanHaveDataRetrieved() throws {
        // must set type on LHS as type can't be inferred from RHS, fair enough
        // (2 x String doesn't necessarily means stringPatchType!)
        let patch: StringPatchItem = Replace(address: "one", with: "X")
        {
            Replace(address: "two", with: "Y") {
                Replace(address: "three", with: "A") {
                    // nothing
                }
                Replace(address: "four", with: "DEF")
            }
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 1, "Expected to find 1 child content patches (1st level)")

        let level_one_patch = patch.contentPatch!.contentPatches[0]

        if case let .replace(address) = level_one_patch.patchSpec, address == "two" { } else {
            XCTFail("Expected patch to equal .replace('two')")
        }

        XCTAssertEqual(level_one_patch.contentPatch?.contentPatches.count, 2, "Expected to find 2 child content patches (1st level)")

        let level_two_patch_0 = level_one_patch.contentPatch!.contentPatches[0]
        let level_two_patch_1 = level_one_patch.contentPatch!.contentPatches[1]

        if case let .replace(address) = level_two_patch_0.patchSpec, address == "three" { } else {
            XCTFail("Expected patch to equal .replace('three')")
        }
        XCTAssertEqual(level_two_patch_0.contentPatch?.contentPatches.count, 0, "Expected to find 0 child content patches (2nd level child 0)")

        if case let .replace(address) = level_two_patch_1.patchSpec, address == "four" { } else {
            XCTFail("Expected patch to equal .replace('four')")
        }
        XCTAssertEqual(level_two_patch_1.contentPatch?.contentPatches.count, 0, "Expected to find 0 child content patches (2nd level child 1)")
    }

    // MARK: - All in one tests
    func test_DSL_allFeaturesInOne() throws {

        let patches: [StringPatchItem] = [
            Replace(address: "one", with: "two"),
            Replace(address: "two", with: "three"),
            Replace(address: "three", with: "four")
        ]

        let trueCondition = true
        let falseCondition = false

        let patchedContent: PatchedString = Content("zero") {

            Replace(address: "zero", with: "one")

            Replace(address: "horse", withContent: makeUser(name: "horsey", address: "a city"))

            for index in 0...2 {
                if trueCondition {
                    patches[index]
                }
                patches[index]
            }

            if falseCondition { }
            else {
                Replace(address: "three", with: "four")
            }

            if falseCondition {
                Replace(address: "should not appear", with: "in final tree")
            }

            for patch in patches {
                patch
            }
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 12, "Unexpected number of items in patch list")
        try patchedContent.testReducers(expectedContent: "four")
    }
}

// MARK: - Helpers
extension PatchouliCoreTests {
    func makeUser(name: String, address: String) -> PatchedString {
        Content("mike") {
            Replace(address: "name_field", with: name)
            Replace(address: "address_field", with: address)
        }
    }
}

// reducer tests
extension PatchouliCoreTests {
    // TODO test that a stub reducer (protocol witness) has its functions invoked
}
