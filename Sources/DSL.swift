// ----------------------------------------------------------------------------------------------------
// DSL support
// The intermediate types that our results builder makes into a structure.

//
// current issues:
//
//   see this comment in core unit test:
//     so we can't have patch alongside the for... because of variadic not
//     taking array of patches (which the for produce)!
//     This means we're limited to using if and if...else in isolation for now.
//     Maybe rethink fundamental result builder design...
//     But don't want to make this too complicated.
//

// [ ] Add tip on writing your own patcher - typically, what to do in what order.
// [ ] Add advice to readme about having your own pass-along DSL. Reasons:
//       1. Can remove actions your patcher might not support; kinder
//          for user to not be able to find a function than to get
//          a runtime error when they call reduce() (BUT the error
//          does tell them that it's not supported)
//       2. A pass-along DSL can rename some params to be nicer for
//          the domain. For example, JSON Patch would use param label 'path: '
//          instead of 'address: '
//
// [ ] Add readme section at end on 'lessons learned/thoughts' etc:
//        e.g. "this sounds like a simple thing but size of project was
//        ideal for provoking some interesting decision making, and touching
//        on some nice things like Protocol Witnesses (maybe mention the initial
//        attempt with protocols that just got a bit... foamy; then the clarity
//        of going with PWs.)
//

// MARK: - Result builder
import Foundation

@resultBuilder
public struct AddressedPatchItemsBuilder<T: PatchType> {
    // If we can use variadics, we're not prone to the "<= 10 items" limitation seen
    // in SwiftUI (due to needing implementation by lots of funcs to match all possible param counts!)

    // empty block to empty list
    public static func buildBlock() -> [AddressedPatch<T>] { [AddressedPatch<T>]() }

    // variadic of lists to list
    public static func buildBlock(_ patchContentItems: [AddressedPatch<T>]...) -> [AddressedPatch<T>] {
        patchContentItems.flatMap { $0 }
    }



    // single to list
    public static func buildBlock(_ patchContentItems: AddressedPatch<T>) -> [AddressedPatch<T>] {
        [patchContentItems]
    }

    // list to list
    public static func buildBlock(_ patchContentItems: [AddressedPatch<T>]) -> [AddressedPatch<T>] {
        patchContentItems
    }

    public static func buildArray(_ components: [[AddressedPatch<T>]]) -> [AddressedPatch<T>] {
        components.flatMap { $0 }
    }
    
    // this is for when the entire patch list is nil (it's optional)
    public static func buildOptional(_ component: [AddressedPatch<T>]?) -> [AddressedPatch<T>] {
        component ?? []
    }


    public static func buildEither(first component: [AddressedPatch<T>]) -> [AddressedPatch<T>] {
        component
    }
    
    public static func buildEither(second component: [AddressedPatch<T>]) -> [AddressedPatch<T>] {
        component
    }

    // Optional patch item handling
    public static func buildExpression(_ addressedPatch: AddressedPatch<T>?) -> [AddressedPatch<T>] {
        [addressedPatch ?? .empty]
    }

    public static func buildExpression(_ addressedPatch: [AddressedPatch<T>]?) -> [AddressedPatch<T>] {
        addressedPatch ?? [.empty]
    }

    // Prune out .empty patch items from list; they can be created from the optional patch handling.
    public static func buildFinalResult(_ component: [AddressedPatch<T>]) -> [AddressedPatch<T>] {
        component.filter { !$0.isEmpty }
    }
    
    // TODO if and if ... else.
}

// MARK: - Generic primitives for DSL:

// MARK: - Content

public func Content<T: PatchType>(_ content: T.ContentType,
                                  @AddressedPatchItemsBuilder<T> patchedBy patchItems: PatchListProducer<T> = { AddressedPatch.emptyPatchList })
        -> PatchedContent<T> {

    PatchedContent(content: content, contentPatches: patchItems())
}

// makeContent?
public func Content<T: PatchType>(_ content: T.ContentType,
                                  patchList: [AddressedPatch<T>])
        -> PatchedContent<T> {

    PatchedContent(content: content, contentPatches: patchList)
}

// MARK: Add

public func Add<T: PatchType>(address: T.AddressType,
                              content: PatchedContent<T>)
            -> AddressedPatch<T> {

    return AddressedPatch(patchSpec: PatchSpec.add(address),
                          contentPatch: content)
}

public func Add<T: PatchType>(address: T.AddressType,
                              simpleContent: T.ContentType,
                              @AddressedPatchItemsBuilder<T> patchedBy patchItems: PatchListProducer<T> = { AddressedPatch.emptyPatchList })
            -> AddressedPatch<T> {

    Add(address: address,
        content: PatchedContent(content: simpleContent,
                                contentPatches: patchItems()))
}

// MARK: Remove

public func Remove<T: PatchType>(address: T.AddressType) -> AddressedPatch<T> {

    AddressedPatch(patchSpec: .delete(address))
}

// MARK: - Patch

/// Patch at Address with given Content.
public func Replace<T: PatchType>(address: T.AddressType,
                                  withContent content: PatchedContent<T>)
        -> AddressedPatch<T> {

    return AddressedPatch(patchSpec: .replace(address),
                          contentPatch: content)
}

/// Convenience that wraps 'simpleContent' in a Content() with optional sub-patches
///
/// Examples:
///
///     let p1 = Patch1(address: "lex", with: "xle")
///
///     Patch1(address: "hunsley", with:"one two, one two") {
///         Patch1(address: "one", with: "foo")
///         Patch1(address: "two", with: "bar")
///     }
///
///     // make 'withPatchedSimpleContent' variant? For when list follows...?
public func Replace<T: PatchType>(address: T.AddressType,
                                  with simpleContent: T.ContentType,
                                  @AddressedPatchItemsBuilder<T> patchedBy patchItems: PatchListProducer<T> = { AddressedPatch.emptyPatchList })
        -> AddressedPatch<T> {

            Replace(address: address,
                    withContent: PatchedContent(content: simpleContent,
                                                contentPatches: patchItems()))
}

// MARK: Copy

public func Copy<T: PatchType>(fromAddress: T.AddressType,
                               toAddress: T.AddressType)
        -> AddressedPatch<T> {

    return AddressedPatch(patchSpec: .move(fromAddress, toAddress))
}

// MARK: Move

public func Move<T: PatchType>(fromAddress: T.AddressType,
                               toAddress: T.AddressType)
        -> AddressedPatch<T> {

    return AddressedPatch(patchSpec: .move(fromAddress, toAddress))
}

// MARK: Test

public func Test<T: PatchType>(address: T.AddressType,
                               content: PatchedContent<T>? = nil)
        -> AddressedPatch<T> {

    AddressedPatch(patchSpec: .test(address),
                   contentPatch: content)
}
