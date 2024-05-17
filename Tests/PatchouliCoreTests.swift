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
        let nonNilOptionalPatch: StringPatchItem? = Patch(address: "tues", with: "weds")

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
            Patch(address: "tues", with: "weds")
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 1, "Unexpected number of items in patch list")
    }

    func test_DSL_ContentWithThreePatchesMakesPatchListWithThreeItem() throws {
        let patchedContent: PatchedString = Content("one two three four") {
            Patch(address: "one", with: "X")
            Patch(address: "two", with: "Y")
            Patch(address: "three", with: "Z")
        }
        XCTAssertEqual(patchedContent.contentPatches.count, 3, "Unexpected number of items in patch list")
    }

    // MARK: - Loops and For

    func test_DSL_forLoopWorks() throws {
        let patch: [StringPatchItem] = [
            Patch(address: "one", with: "two"),
            Patch(address: "two", with: "three"),
            Patch(address: "three", with: "four"),
        ]

        var patchedContent: PatchedString = Content("one") {
            for index in 0...2 {
                patch[index]
            }
            Patch(address: "three", with: "four")
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 4, "Unexpected number of items in patch list")
//        XCTAssertEqual(try patchedContent.reduced(), "four", "Didn't find expected result from reduce")

        // try in-place reducer (inout) -- this works. Not sure how much sense inout
        // makes with json/strings though! But generally, having the option might be good.
        try patchedContent.reduce()

        XCTAssertEqual(patchedContent.content, "four", "Didn't find expected result from reduce")
    }

    func test_DSL_forInWorks() throws {
        let patches: [StringPatchItem] = [
            Patch(address: "one", with: "two"),
            Patch(address: "two", with: "three"),
            Patch(address: "three", with: "four"),
        ]

        let patchedContent: PatchedString = Content("one") {
            // i have disabled build array for now
            for patch in patches {
                patch
            }
            patches[1]
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 4, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "four", "Didn't find expected result from reduce")
    }

    // MARK: - If

    func test_DSL_ifTrueWorks() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "two")
        let trueCondition = true

        let patchedContent: PatchedString = Content("one") {
            if trueCondition {
                patch
            }
            patch
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "two", "Didn't find expected result from reduce")
    }

    func test_DSL_ifFalseWorks() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "two")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            // do i need to move to making it a list of lists? then we flatten in the prepare bit.
            if falseCondition {
                patch
            }
            Patch(address: "tree", with: "horse")
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 1, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "one", "Didn't find expected result from reduce")
    }

    func test_DSL_ifElseTrueWorks() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "two")
        let otherPatch: StringPatchItem = Patch(address: "one", with: "horse")

        let falseCondition = true

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "tree", with: "horse")

            if falseCondition {
                patch
            }
            else {
                otherPatch
            }
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "two", "Didn't find expected result from reduce")
    }

    func test_DSL_ifElseFalseWorks() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "two")
        let otherPatch: StringPatchItem = Patch(address: "one", with: "horse")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            if falseCondition {
                otherPatch
            }
            else {
                patch
            }
            Patch(address: "tree", with: "horse")
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "two", "Didn't find expected result from reduce")
    }

    func test_DSL_ifElseFalseContainingPatchedContentWorks() throws {
        let patch: StringPatchItem = Patch(address: "one", withContent: Content("two") {
            Patch(address: "two", with: "three")
        })

        let otherPatch: StringPatchItem = Patch(address: "one", with: "horse")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "tree", with: "horse")

            if falseCondition {
                otherPatch
            }
            else {
                patch
            }
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "three", "Didn't find expected result from reduce")
    }

    func test_DSL_ifElseFalseContainingOptionalPatchedContentWorks() throws {
        let patch: StringPatchItem? = Patch(address: "one", withContent: Content("two") {
            Patch(address: "two", with: "three")
        })

        let otherPatch: StringPatchItem? = Patch(address: "one", with: "horse")
        let falseCondition = false

        let patchedContent: PatchedString = Content("one") {
            if falseCondition {
                otherPatch
            }
            else {
                patch
            }
            Patch(address: "tree", with: "horse")
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 2, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "three", "Didn't find expected result from reduce")
    }

    // doesn't work, same as the if next to Patch issue: variadics not taking an array, and if/for produces an array.
    func test_DSL_siblingIfsWorks() throws {
        let patch: StringPatchItem? = Patch(address: "one", with: "two")
        let patch2: StringPatchItem = Patch(address: "two", with: "three")
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
        XCTAssertEqual(try patchedContent.reduced(), "three", "Didn't find expected result from reduce")
    }

    // MARK: - Patches

    func test_DSL_patchWithSimpleDataAndNoPatchListCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "X")

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 0, "Expected to find 0 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndEmptyPatchListCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "X") {
            // nothing
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 0, "Expected to find 0 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndPatchListOfOneItemCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "X") {
            Patch(address: "two", with: "Y")
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 1, "Expected to find 1 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndPatchListOfTwoItemsCanHaveDataRetrieved() throws {
        let patch: StringPatchItem = Patch(address: "one", with: "X") {
            Patch(address: "two", with: "Y")
            Patch(address: "three", with: "Z")
        }

        if case let .replace(address) = patch.patchSpec, address == "one" { } else {
            XCTFail("Expected patch to equal .replace('X')")
        }

        XCTAssertEqual(patch.contentPatch?.contentPatches.count, 2, "Expected to find 1 child content patches")
    }

    func test_DSL_patchWithSimpleDataAndNestedPatchListOfOneItemTwoItemsCanHaveDataRetrieved() throws {
        // must set type on LHS as type can't be inferred from RHS, fair enough
        // (2 x String doesn't necessarily means stringPatchType!)
        let patch: StringPatchItem = Patch(address: "one", with: "X")
        {
            Patch(address: "two", with: "Y") {
                Patch(address: "three", with: "A") {
                    // nothing
                }
                Patch(address: "four", with: "DEF")
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
            Patch(address: "one", with: "two"),
            Patch(address: "two", with: "three"),
            Patch(address: "three", with: "four")
        ]

        let trueCondition = true
        let falseCondition = false

        let patchedContent: PatchedString = Content("zero") {

            Patch(address: "zero", with: "one")

            Patch(address: "horse", withContent: makeUser(name: "horsey", address: "a city"))

            for index in 0...2 {
                if trueCondition {
                    patches[index]
                }
                patches[index]
            }

            if falseCondition { }
            else {
                Patch(address: "three", with: "four")
            }

            if falseCondition {
                Patch(address: "should not appear", with: "in final tree")
            }

            for patch in patches {
                patch
            }
        }

        XCTAssertEqual(patchedContent.contentPatches.count, 12, "Unexpected number of items in patch list")
        XCTAssertEqual(try patchedContent.reduced(), "four", "Didn't find expected result from reduce")
    }
}

// MARK: - Helpers
extension PatchouliCoreTests {
    func makeUser(name: String, address: String) -> PatchedString {
        Content("mike") {
            Patch(address: "name_field", with: name)
            Patch(address: "address_field", with: address)
        }
    }
}

// reducer tests
extension PatchouliCoreTests {
    // TODO test that a stub reducer (protocol witness) has its functions invoked
}
