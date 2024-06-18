//
//  AddressedPatchItemsBuilder.swift
//  PatchouliCore
//
//  Created by Alex Hunsley on 18/06/2024.
//

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
