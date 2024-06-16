// ----------------------------------------------------------------------------------------------------
// DSL support
// The intermediate types that our results builder makes into a structure.

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
                              // herus: rename param to patchedContent?
                              // then simpleContent becomes just content?
                              content: PatchedContent<T>)
            -> AddressedPatch<T> {

    AddressedPatch(patchSpec: PatchSpec.add(address),
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

    AddressedPatch(patchSpec: .remove(address))
}

// MARK: - Patch

/// Patch at Address with given Content.
public func Replace<T: PatchType>(address: T.AddressType,
                                  withContent content: PatchedContent<T>)
        -> AddressedPatch<T> {

    AddressedPatch(patchSpec: .replace(address),
                   contentPatch: content)
}

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

    AddressedPatch(patchSpec: .copy(fromAddress, toAddress))
}

// MARK: Move

public func Move<T: PatchType>(fromAddress: T.AddressType,
                               toAddress: T.AddressType)
        -> AddressedPatch<T> {

    AddressedPatch(patchSpec: .move(fromAddress, toAddress))
}

// MARK: Test

public func Test<T: PatchType>(address: T.AddressType,
                               expectedSimpleContent: T.ContentType)
        -> AddressedPatch<T> {

    AddressedPatch(patchSpec: .test(expectedSimpleContent, address))
}
