<div align="center">
<img src="https://github.com/alexhunsley/patchouli-jsonpatch/blob/main/Tests/Resources/patchouli-core-logo-1-scaled-378x379.jpg">
</div>

[![Apache 2 License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexhunsley%2Fpatchouli-core%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/alexhunsley/patchouli-core)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexhunsley%2Fpatchouli-core%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/alexhunsley/patchouli-core)
[![Build System](https://img.shields.io/badge/dependency%20management-spm-yellow.svg)](https://swift.org/package-manager/)

Patchouli Core is a generic patching engine and DSL for Swift, based on JSON Patch's operations (`Add`, `Remove`, `Replace`, `Copy`, `Move`, and `Test`).

It is used by [Patchouli JSON](https://github.com/alexhunsley/patchouli-jsonpatch).

# How Patchouli Core works
It has two major parts: a DSL that feels similar to SwiftUI, for constructing the patch, and a tree reducer which then performs the patching using appropriate functions.

The representation of patchable data and the DSL are both generic, which means that you can write a patcher for anything you like.

Patchouli Core contains a toy string patcher for demonstration purposes:

```swift
// Input: "Hello World"
// Patched result: "Goodbye my friend"

let stringPatchContent: StringPatchContent = Content("Hello World") {
    Replace(address: "Hello", with: "Goodbye")
    Replace(address: "World", with: "my friend")
}

let result: String = try stringPatchContent.reduced()
```

# Writing a custom patcher using Patchouli Core

Patchouli Core contains a toy patcher example: a string patcher (see `StringPatchType.swift`). We'll use that here to demonstrate how to write a patcher for any data type you like.

Firstly, we have to define what the content type is that we're patching, and what the address type is. An address is some data that can locate one or more parts in a piece of the content type.

```swift
public struct StringPatchType: PatchType {
    // ContentType: A string patcher works on strings
    public typealias ContentType = String

    // AddressType: we identify one or more parts of a string (for patching) with a (sub)string.
    public typealias AddressType = String
}
```

To this struct we add a definition of `empty`; this is just an instance of `ContentType` that is considered 'empty content':

```swift
   public static var emptyContent: ContentType = ""
```

And finally, our struct needs to be told how to perform the various kinds of patching operation possible. To do this, we add a **protocol witness** to the struct, which looks like this:

```swift
    /// The Protocol Witness used by the reducer
    static public let patcher = Patchable<StringPatchType>(
        added: { (container: String, content: String, address: String) -> String in
            // We interpret 'add' in string matching to mean "place a copy of content
            // before every occurence of the address".
            // if the address isn't found in the string, we don't care.
            container.prefixing(address, with: content)
        },
        removed: { (container: String, address: String) in
            container.replacingOccurrences(of: address, with: "")
        },
        replaced: { (container: String, replacement: String, address: String) -> String in
            // NB this replaces all occurrences!
            // But that’s expected for a content-based Address
            container.replacingOccurrences(of: address, with: replacement)
        },
        // a 'copy' operation doesn't really make sense for a string pather, so we don't provide one
        //    copied: {
        moved: { (container: String, fromAddress: String, toAddress: String) -> String in
            container
                .replacingOccurrences(of: fromAddress, with: "")
                .replacingOccurrences(of: toAddress, with: fromAddress)
        },
        // we don't care about the expectedContent (2nd param) for our 'test' operation,
        // because in this string patcher, the address *is* the content
        test: { (container: String, _: String, address: String) in
            if !container.contains(address) {
                // your implementation must throw this error when the test operation has failed
                throw PatchouliError<StringPatchType>.testFailed(container, address, address)
            }
            return container
        }
    )
```

Note that we don't provide an implementation of `copy` for our string patcher. Every kind of operation is optional when you write a patcher, but providing at least one is recommended :)
(If the user of the DSL tries to execute a `copy` operation with this string patcher, the call to `reduced()` will throw a descriptive error.)

And that's all you need to do to get a working custom patcher.

To pull it all together, the entire `StringPatchType` definition is this:

```swift
public struct StringPatchType: PatchType {
    // ContentType: A string patcher works on strings
    public typealias ContentType = String

    // AddressType: we identify one or more parts of a string (for patching) with a (sub)string.
    public typealias AddressType = String

    public static var emptyContent: ContentType = ""

    /// The Protocol Witness used by the reducer
    static public let patcher = Patchable<StringPatchType>(
        added: { (container: String, content: String, address: String) -> String in
            // We interpret 'add' in string matching to mean "place a copy of content
            // before every occurence of the address".
            // if the address isn't found in the string, we don't care.
            container.prefixing(address, with: content)
        },
        removed: { (container: String, address: String) in
            container.replacingOccurrences(of: address, with: "")
        },
        replaced: { (container: String, replacement: String, address: String) -> String in
            // NB this replaces all occurrences!
            // But that’s expected for a content-based Address
            container.replacingOccurrences(of: address, with: replacement)
        },
        // a 'copy' operation doesn't really make sense for a string pather, so we don't provide one
        //    copied: {
        moved: { (container: String, fromAddress: String, toAddress: String) -> String in
            container
                .replacingOccurrences(of: fromAddress, with: "")
                .replacingOccurrences(of: toAddress, with: fromAddress)
        },
        // we don't care about the expectedContent (2nd param) for our 'test' operation,
        // because in this string patcher, the address *is* the content
        test: { (container: String, _: String, address: String) in
            if !container.contains(address) {
                // your implementation must throw this error when the test operation has failed
                throw PatchouliError<StringPatchType>.testFailed(container, address, address)
            }
            return container
        }
    )
}
```

# Refining your custom patcher

The above is the bare minimum for a custom patcher. You can improve it beyond that by adding conveneniences for the DSL.

For example, the toy String patcher contains the following convenience:

```swift
/// Convenience for string patcher's test method that doesn't require an address param
/// (the expected content is all we need, we're checking to see if it's in the string)
public func Test(expectedContent: String) -> AddressedPatch<StringPatchType> {
    // Note we give expectedContent for the address as well as the expectedContent,
    // as it's required for this patcher func (but not used in this string patcher)
    return AddressedPatch(patchSpec: .test(expectedContent, expectedContent),
                          contentPatch: PatchedContent<StringPatchType>(content: expectedContent))
}
```

# License

```
Copyright 2024 Alex Hunsley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
