//
//  DSL+StringPatchType.swift
//  PatchouliCore
//
//  Created by Alex Hunsley on 23/05/2024.
//

import Foundation

/// Conveience for string patcher's test method that doesn't require an address param
/// (the expected content is all we need, we're checking to see if it's in the string)
public func Test(expectedContent: String) -> AddressedPatch<StringPatchType> {
    // Note we give expectedContent for the address as well as the expectedContent,
    // as it's required for this patcher func (but not used)
    return AddressedPatch(patchSpec: .test(expectedContent, expectedContent),
                          contentPatch: PatchedContent<StringPatchType>(content: expectedContent))
}
