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

    @AddressedPatchItemsBuilder<StringPatchType> func makeSamplePatchList() -> StringPatchList {
        Replace(address: "one", with: "hello") {
            Replace(address: "hello", with: "goodbye")
        }
        Replace(address: "goodbye", with: "auf wiedersehen")
    }

    func test_forGithubDocs() {
        // Makes a "no nothing" patched string using the DSL
        let trivialPatchedString: PatchedString = Content("one")

        // Result: "one"
        XCTAssertEqual(try trivialPatchedString.reduced(), "one")

        // make a patch list using a helper func
        let patchList = makeSamplePatchList()

        print(patchList)

        let patchSpecOne: PatchedString = Content("one", patchList: patchList)
        XCTAssertEqual(try patchSpecOne.reduced(), "auf wiedersehen")

        // we can use a patch list multiple times with different content
        let patchSpecTwo: PatchedString = Content("two", patchList: patchList)
        XCTAssertEqual(try patchSpecTwo.reduced(), "two")
    }

    ////////////////////
    func test_stringReducer_ContentWithoutPatchingWorks() throws {

        let patchedContent: PatchedString = Content("one")

        XCTAssertEqual(try patchedContent.reduced(), "one")
    }

    func test_stringReducer_replaceWorks() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello")
        }

        XCTAssertEqual(try patchedContent.reduced(), "hello")
    }

    func test_stringReducer_nestedReplaceWorks() throws {
        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello") {
                Replace(address: "hello", with: "goodbye")
            }
        }
        XCTAssertEqual(try patchedContent.reduced(), "goodbye")
    }

    func test_stringReducer_reducerIsDepthFirst() throws {
        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello") {
                Replace(address: "hello", with: "goodbye")
            }
            Replace(address: "goodbye", with: "auf wiedersehen")
        }
        XCTAssertEqual(try patchedContent.reduced(), "auf wiedersehen")
    }

    func test_stringReducer_ReplaceIgnoresUnmatchedPatches() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "", with: "hello")
            Replace(address: "sonet", with: "hello")
            Replace(address: "a house", with: "hello")
        }
        XCTAssertEqual(try patchedContent.reduced(), "one")
    }

    // TODO use the reduce+reduced 2 in 1 helper (core)
    func test_stringReducer_addWorks() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Add(address: "digitation", simpleContent: "FOO")
        }
        XCTAssertEqual(try patchedContent.reduced(), "prestiFOOdigitation")
    }

    func test_stringReducer_addWorksWithMultipleMatches() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Add(address: "t", simpleContent: "_")
        }
        XCTAssertEqual(try patchedContent.reduced(), "pres_tidigi_ta_tion")
    }

    // TODO use the reduce+reduced 2 in 1 helper (core)
    func test_stringReducer_removeWorks() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Remove(address: "digitation")
        }
        XCTAssertEqual(try patchedContent.reduced(), "presti")
    }

    func test_stringReducer_removeWorksWithMultipleMatches() throws {

        let patchedContent: PatchedString = Content("prestidigitation rest prestidigitation") {
            Remove(address: "rest")
        }
        XCTAssertEqual(try patchedContent.reduced(), "pidigitation  pidigitation")
    }

    func test_stringReducer_moveWorksFromSingleToSingle() throws {

        let patchedContent: PatchedString = Content("repetitiv_horse_e") {
            Move(fromAddress: "pet", toAddress: "_horse_")
        }
        XCTAssertEqual(try patchedContent.reduced(), "reitivpete")
    }

    func test_stringReducer_moveWorksFromMultiToSingle() throws {

        let patchedContent: PatchedString = Content("repetitive") {
            Move(fromAddress: "ti", toAddress: "re")
        }
        XCTAssertEqual(try patchedContent.reduced(), "tipeve")
    }

    func test_stringReducer_moveWorksFromSingleToMulti() throws {

        let patchedContent: PatchedString = Content("repetitive") {
            Move(fromAddress: "tive", toAddress: "e")
        }
        XCTAssertEqual(try patchedContent.reduced(), "rtiveptiveti")
    }

    func test_stringReducer_moveWorksFromMultiToMulti() throws {

        let patchedContent: PatchedString = Content("repetitive rep") {
            Move(fromAddress: "ti", toAddress: "re")
        }
        XCTAssertEqual(try patchedContent.reduced(), "tipeve tip")
    }

    // MARK: - Strict order of reducer application

    func test_stringReducer_SubsequentPatchSeesPreviousPatchResult() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello")
            Replace(address: "hello", with: "bye")
        }
        XCTAssertEqual(try patchedContent.reduced(), "bye")
    }

    func test_stringReducer_PatchDoesNotSeesNextPatchResult() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "hello", with: "bye")
            Replace(address: "one", with: "hello")
        }
        XCTAssertEqual(try patchedContent.reduced(), "hello")
    }

    // MARK: - Missing reducer funcs throw errors

    func test_stringReducer_missingReplaceFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello")
        }

        let noReplaceFunctionPatcher = StringPatchType.testingPatcher(nilReplacedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noReplaceFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.mutatingReplaceNotSupported = error else {
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

            Remove(address: "hi")
        }

        let noDeletedFunctionPatcher = StringPatchType.testingPatcher(nilRemovedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noDeletedFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.mutatingRemoveNotSupported = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
        }
    }

    // ... and do same for copy, move which legit don't have funcs added
    func test_stringReducer_missingAddedFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            // magic sauce to get type inference going!
            // https://stackoverflow.com/q/67951741/348476
            Add(address: "1", simpleContent: "2")
            Add(address: "1", content: Content("ASd"))
        }

        let noAddFunctionPatcher = StringPatchType.testingPatcher(nilAddedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noAddFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.mutatingAddNotSupported = error else {
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
