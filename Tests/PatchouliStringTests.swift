// MARK: - String reducer tests
import XCTest

@testable import PatchouliCore

extension PatchouliCoreTests {
    func test_stringReducer_producesExpectedResult() throws {

        let patchedContent: PatchedString = Content("one")

        try patchedContent.testReducers(expectedContent: "one")
    }
}

extension PatchouliCoreTests {

    @AddressedPatchItemsBuilder<StringPatchType> func makeSamplePatchList() -> StringPatchList {
        Replace(address: "one", with: "hello") {
            Replace(address: "hello", with: "goodbye")
        }
        Replace(address: "goodbye", with: "auf wiedersehen")
    }

    func test_forGithubDocs() throws {
        // Makes a "no nothing" patched string using the DSL
        let trivialPatchedString: PatchedString = Content("one")

        XCTAssertEqual(try trivialPatchedString.reduced(), "one")

        // make a patch list using a helper func
        let patchList = makeSamplePatchList()

        print(patchList)

        let patchSpecOne: PatchedString = Content("one", patchList: patchList)
        try patchSpecOne.testReducers(expectedContent: "auf wiedersehen")

        // we can use a patch list multiple times with different content
        let patchSpecTwo: PatchedString = Content("two", patchList: patchList)
        try patchSpecTwo.testReducers(expectedContent: "two")
    }

    ////////////////////
    func test_stringReducer_ContentWithoutPatchingWorks() throws {
        let patchedContent: PatchedString = Content("one")
        try patchedContent.testReducers(expectedContent: "one")
    }

    func test_stringReducer_replaceWorks() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello")
        }
        try patchedContent.testReducers(expectedContent: "hello")
    }

    // herus THIS SNOULD FAIL you crazy person!
    // reducer starts deepest firsst!
    func test_stringReducer_nestedReplaceWorks() throws {
        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello") {
                Replace(address: "hello", with: "goodbye")
            }
        }
        try patchedContent.testReducers(expectedContent: "goodbye")
    }

    func test_stringReducer_reducerIsDepthFirst() throws {
        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello") {
                Replace(address: "hello", with: "goodbye")
            }
            Replace(address: "goodbye", with: "auf wiedersehen")
        }
        try patchedContent.testReducers(expectedContent: "auf wiedersehen")
    }

    func test_stringReducer_ReplaceIgnoresUnmatchedPatches() throws {
        let patchedContent: PatchedString = Content("one") {
            Replace(address: "", with: "hello")
            Replace(address: "sonet", with: "afternoon")
            Replace(address: "a house", with: "bye")
        }
        try patchedContent.testReducers(expectedContent: "one")
    }

    func test_stringReducer_addWorks() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Add(address: "digitation", simpleContent: "FOO")
        }
        try patchedContent.testReducers(expectedContent: "prestiFOOdigitation")
    }

    func test_stringReducer_addWorksWithMultipleMatches() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Add(address: "t", simpleContent: "_")
        }
        try patchedContent.testReducers(expectedContent: "pres_tidigi_ta_tion")
    }

    func test_stringReducer_removeWorks() throws {

        let patchedContent: PatchedString = Content("prestidigitation") {
            Remove(address: "digitation")
        }
        try patchedContent.testReducers(expectedContent: "presti")
    }

    func test_stringReducer_removeWorksWithMultipleMatches() throws {

        let patchedContent: PatchedString = Content("prestidigitation rest prestidigitation") {
            Remove(address: "rest")
        }
        try patchedContent.testReducers(expectedContent: "pidigitation  pidigitation")
    }

    func test_stringReducer_moveWorksFromSingleToSingle() throws {

        let patchedContent: PatchedString = Content("repetitiv_horse_e") {
            Move(fromAddress: "pet", toAddress: "_horse_")
        }
        try patchedContent.testReducers(expectedContent: "reitivpete")
    }

    func test_stringReducer_moveWorksFromMultiToSingle() throws {

        let patchedContent: PatchedString = Content("repetitive") {
            Move(fromAddress: "ti", toAddress: "re")
        }
        try patchedContent.testReducers(expectedContent: "tipeve")
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
        try patchedContent.testReducers(expectedContent: "tipeve tip")
    }

    func test_stringReducer_testWorks() throws {

        let patchedContent: PatchedString = Content("repetitive rep") {
            // NB it's only using the expected content here! not the address.
            Test(expectedContent: "titive")
            Test(expectedContent: "it")
            Test(expectedContent: "p")
            Add(address: "rep", simpleContent: "rap")
            Test(expectedContent: "raprep")
        }
        patchedContent.assertReducersDoNotThrow()
    }

    // MARK: - Strict order of reducer application

    func test_stringReducer_SubsequentPatchSeesPreviousPatchResult() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello")
            Replace(address: "hello", with: "bye")
        }
        try patchedContent.testReducers(expectedContent: "bye")
    }

    func test_stringReducer_PatchDoesNotSeesNextPatchResult() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "hello", with: "bye")
            Replace(address: "one", with: "hello")
        }
        try patchedContent.testReducers(expectedContent: "hello")
    }

    // MARK: - Missing reducer funcs throw errors

    func test_stringReducer_missingReplaceFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            Replace(address: "one", with: "hello")
        }

        let noReplaceFunctionPatcher = StringPatchType.testingPatcher(nilReplacedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noReplaceFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.replaceNotSupported = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
        }
    }

    func test_stringReducer_missingDeletedFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            Remove(address: "hi")
        }

        let noRemovedFunctionPatcher = StringPatchType.testingPatcher(nilRemovedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noRemovedFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.removeNotSupported = error else {
                XCTFail("Didn't get expected removed missing error: got \(error)")
                return
            }
        }
    }

    // ... and do same for copy, move which legit don't have funcs added
    func test_stringReducer_missingAddedFunctionThrowsError() throws {

        let patchedContent: PatchedString = Content("one") {
            Add(address: "1", simpleContent: "2")
            Add(address: "1", content: Content("ASd"))
        }

        let noAddFunctionPatcher = StringPatchType.testingPatcher(nilAddedFunc: true)

        XCTAssertThrowsError(try patchedContent.reduced(noAddFunctionPatcher)) { error in
            guard case PatchouliError<StringPatchType>.addNotSupported = error else {
                XCTFail("Didn't get expected replace missing error: got \(error)")
                return
            }
        }
    }

    func test_stringReducer_ifTestSucceeds_thenPatchIsApplied() throws {

        let inputString = "one three"
        let patchedContent: PatchedString = Content(inputString) {
            Add(address: "three", simpleContent: "hello ")
            // test an existing address
            Test(expectedContent: "one")
        }
        let reduced = try patchedContent.reduced()
        XCTAssertEqual(reduced, "one hello three")
    }

    func test_stringReducer_ifTestFails_thenPatchNotApplied() throws {

        let horseContent = "horse"

        let inputString = "one three"
        let patchedContent: PatchedString = Content(inputString) {
            Add(address: "three", simpleContent: " hello ")
            // test a non-existent address
            Test(expectedContent: horseContent)
        }
        let reduced = try patchedContent.reduced()
        XCTAssertEqual(reduced, inputString)
    }

    func test_stringReducer_passingTestDoesNotThrowError() throws {
        let patchedContent: PatchedString = Content("three one three two") {
            Test(expectedContent: "three")
            Test(expectedContent: "ne th")
        }
        patchedContent.assertReducersDoNotThrow()
    }
}
