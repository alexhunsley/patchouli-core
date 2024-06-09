import Foundation

/// The notocol ('not a protocol') for our in-place patcher protocol witnesses.
/// Note the gerund style name ('-ing', '-able', etc) -- when we see this on
/// a struct, this is a hint that it's a notocol.
///
/// Protocol witness instantiations of this type should lose the
/// gerund style and be named e.g. 'mutablePatcher'.
///
/// (Practically, I wanted to name this struct `PatchableInPlace` (for code completion etc),
/// but linguistically and semantically, mutatingPatchable is the correct name.)
public struct MutatingPatchable<T: PatchType> {
    public typealias C = T.ContentType
    public typealias A = T.AddressType

    // TODO would C A C make more sense? feels like it.
    // But I did C C A for the... ordering of them? Not sure important tho.
    public typealias AddHandler = @Sendable (inout C, C, A) -> Void
    public typealias RemoveHandler = @Sendable (inout C, A) -> Void
    // TODO would C A C make more sense? feels like it.
    public typealias ReplaceHandler = @Sendable (inout C, C, A) -> Void
    public typealias CopyHandler = @Sendable (inout C, A, A) -> Void
    public typealias MoveHandler = @Sendable (inout C, A, A) -> Void
    public typealias TestHandler = @Sendable (C, C, A) throws -> Void

    public let add: AddHandler?
    public let remove: RemoveHandler?
    public let replace: ReplaceHandler?
    public let copy: CopyHandler?
    public let move: MoveHandler?
    // We may eventually want to make this throw (and return Void)
    // in order to let PatchType writers give error information
    // (would be wrapped in the Patchouli 'test failed' error)
    public let test: TestHandler?

    public init(add: AddHandler? = nil,
                remove: RemoveHandler? = nil,
                replace: ReplaceHandler? = nil,
                copy: CopyHandler? = nil,
                move: MoveHandler? = nil,
                test: TestHandler? = nil) {

        self.add = add
        self.remove = remove
        self.replace = replace
        self.copy = copy
        self.move = move
        self.test = test
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
