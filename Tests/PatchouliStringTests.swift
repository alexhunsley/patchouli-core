// MARK: - String reducer tests
import XCTest

@testable import PatchouliCore

extension PatchouliCoreTests {
    func test_stringReducer_producesExpectedResult() throws {

        let patchedContent: PatchedString = Content("one")

        let result = try patchedContent.reduced()

        XCTAssertEqual(result, "one", "Expected 'one' for reducer result")
    }
}

extension PatchouliCoreTests {
    func test_stringReducer_ContentWithoutPatchingWorks() throws {

        let patchedContent: PatchedString = Content("one")

        XCTAssertEqual(try patchedContent.reduced(), "one")
    }

    func test_stringReducer_replaceWorks() throws {

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "one", with: "hello")
        }

        XCTAssertEqual(try patchedContent.reduced(), "hello")
    }

    func test_stringReducer_nestedReplaceWorks() throws {
        let patchedContent: PatchedString = Content("one") {
            Patch(address: "one", with: "hello") {
                Patch(address: "hello", with: "goodbye")
            }
        }
        XCTAssertEqual(try patchedContent.reduced(), "goodbye")
    }

    func test_stringReducer_reducerIsDepthFirst() throws {
        let patchedContent: PatchedString = Content("one") {
            Patch(address: "one", with: "hello") {
                Patch(address: "hello", with: "goodbye")
            }
            Patch(address: "goodbye", with: "auf wiedersehen")
        }
        XCTAssertEqual(try patchedContent.reduced(), "auf wiedersehen")
    }

    func test_stringReducer_ReplaceIgnoresUnmatchedPatches() throws {

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "", with: "hello")
            Patch(address: "sonet", with: "hello")
            Patch(address: "a house", with: "hello")
        }
        XCTAssertEqual(try patchedContent.reduced(), "one")
    }

    func test_stringReducer_deleteWorks() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Delete(address: "digitation")
        }
        XCTAssertEqual(try patchedContent.reduced(), "presti")
    }

    // MARK: - Strict order of reducer application

    func test_stringReducer_SubsequentPatchSeesPreviousPatchResult() throws {

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "one", with: "hello")
            Patch(address: "hello", with: "bye")
        }
        XCTAssertEqual(try patchedContent.reduced(), "bye")
    }

    func test_stringReducer_PatchDoesNotSeesNextPatchResult() throws {

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "hello", with: "bye")
            Patch(address: "one", with: "hello")
        }
        XCTAssertEqual(try patchedContent.reduced(), "hello")
    }

    // MARK: - Missing reducer funcs throw errors

    func test_stringReducer_missingReplaceFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            Patch(address: "one", with: "hello")
        }

        let noReplaceFunctionPatcher = StringPatchType.testingPatcher(nilReplacedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noReplaceFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.witnessMissingReplaceFunction = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
        }
    }

    func test_stringReducer_missingDeletedFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            // magic sauce to get the type inferred.
            // See https://stackoverflow.com/q/67951741/348476
            //  -- we don't need this any more, after moving to
            //     to PatchType2 cont+address holder! Yay.
            //     Needing this should be regarded as a code smell.
            //            AddressedPatchItemsBuilder.buildExpression(Delete(address: "hi"))

            Delete(address: "hi")
        }

        let noDeletedFunctionPatcher = StringPatchType.testingPatcher(nilDeletedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noDeletedFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.witnessMissingDeleteFunction = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
        }
    }

    func test_stringReducer_missingAddedFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            // magic sauce to get type inference going!
            // https://stackoverflow.com/q/67951741/348476
            Add(address: "1", simpleContent: "2")
            Add(address: "1", content: Content("ASd"))
        }

        let noAddFunctionPatcher = StringPatchType.testingPatcher(nilAddedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noAddFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.witnessMissingAddedFunction = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
        }
    }

    func test_stringReducer_failingTestThrowsError() throws {

        let horseAddress = "horse"

        let patchedContent: PatchedString = Content("one three") {
            // test a non-existent address
            Test(address: horseAddress)
        }

        // TODO make the reduce func be default on the patchType? Hence locate it in the patchType...
        XCTAssertThrowsError(try patchedContent.reduced()) { error in
            guard case let PatchouliError<StringPatchType>.testFailed(address) = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
            XCTAssertEqual(address, horseAddress, "Expected \(horseAddress) in .testFailed() error but got \"\(address)\"")
        }
    }

    func test_stringReducer_passingTestDoesNotThrowError() throws {
        let patchedContent: PatchedString = Content("three one three two") {
            // magic sauce to get type inference going!
            // https://stackoverflow.com/q/67951741/348476

            // test an existing address
            Test(address: "three")
        }
        // we expect this to not throw
        _ = try patchedContent.reduced()
    }
}
