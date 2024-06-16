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

    public typealias AddHandler = @Sendable (inout C, C, A) -> Void
    public typealias RemoveHandler = @Sendable (inout C, A) -> Void
    public typealias ReplaceHandler = @Sendable (inout C, C, A) -> Void
    public typealias CopyHandler = @Sendable (inout C, A, A) -> Void
    public typealias MoveHandler = @Sendable (inout C, A, A) -> Void
    public typealias TestHandler = @Sendable (C, C, A) throws -> Void

    public let add: AddHandler?
    public let remove: RemoveHandler?
    public let replace: ReplaceHandler?
    public let copy: CopyHandler?
    public let move: MoveHandler?
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
