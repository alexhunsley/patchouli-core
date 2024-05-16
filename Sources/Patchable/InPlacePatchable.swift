import Foundation

// The notocol ('not a protocol') for our in-place patcher protocol witnesses.
// Note the gerund style name ('-ing', '-able', etc) -- when we see this on
// a struct, this is a hint that it's a notocol.
//
// Protocol witness instantiations of this type should lose the
// gerund style and be named e.g. 'inPlacePatcher'.
//
// (Practically, I wanted to name this struct `PatchableInPlace` (for code completion etc),
// but linguistically and semantically, InPlacePatchable is the correct name.)
public struct InPlacePatchable<T: PatchType> {
    public typealias C = T.ContentType
    public typealias A = T.AddressType

    public typealias ReplaceHandler = @Sendable (inout C, C, A) -> Void

    public let replace: ReplaceHandler?

    public init(replace: ReplaceHandler? = nil) {
        self.replace = replace
    }
}

// Should the mutating (inout) reducer be used by the non-mutating reducer?
// For less repetition.
//
// Perhaps the default is that user can provide a non-mutating `reduced` at
// minimum, and a mutating `reduce` is automatically provided that defaults to
// using the former in the obvious way (call non-mutating one then assign to the
// inout param). BUT we allow the user to provide their own inout reducer if they like
// and think it's worth it!
//
// Look up again `mutating` and the declaration of structs with it if possible it's
// needed somewhere else/later (can't remember the exact situ).
