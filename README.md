# Patchouli Core

is a generic patching engine and DSL for Swift, based on JSON Patch's operations (Add, Remove, Copy, etc).

It is used by Patchouli JSON, an ergonomic implemention of JSON Patch for Swift.

# How Patchouli Core works
It has two major parts: a DSL that feels similar to SwiftUI, for constructing the patch, and a tree reducer which then performs the patching using appropriate functions.

The representation of patchable data and the DSL are both generic, which means that you can write a patcher for anything you like.

Patchouli Core contains a toy string patcher for demonstration purposes:

```
// Input: "Hello World"
// Patched result: "Goodbye my friend"

let stringPatchContent: StringPatchContent = Content("Hello World") {
    Replace(address: "Hello", with: "Goodbye")
    Replace(address: "World", with: "my friend")
}

let result: String = try stringPatchContent.reduced()
```

# How Patchouli Core works

It has two major parts: a DSL that feels similar to SwiftUI, for constructing the patch, and a tree reducer which then performs the patching using appropriate functions.

The representation of patchable data and the DSL are both generic, which means that you can write a patcher for anything you like.
