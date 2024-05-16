import Foundation

// The notocol ('not a protocol') for our patcher protocol witnesses.
// Note the gerund style name ('-ing', '-able', etc) -- when we see this on
// a struct, this is a hint that it's a notocol.
//
// Protocol witness instantiations of this type should lose the
// gerund style and be named e.g. 'patcher'.
public struct Patchable<T: PatchType> {
    public typealias C = T.ContentType
    public typealias A = T.AddressType

    public typealias AddedHandler = @Sendable (C, C, A) -> C
    public typealias ReplacedHandler = @Sendable (C, C, A) -> C
    public typealias MovedHandler = @Sendable (C, A, A) -> C
    public typealias DeletedHandler = @Sendable (C, A) -> C
    public typealias TestHandler = @Sendable (C, A) -> Bool

    public typealias ReplaceHandler = @Sendable (inout C, C, A) -> Void

    public let added: AddedHandler?
    public let replaced: ReplacedHandler?
    public let replace: ReplaceHandler?
    public let moved: MovedHandler?
    public let deleted: DeletedHandler?
    // We may eventually want to make this throw (and return Void)
    // in order to let PatchType writers give error information
    // (would be wrapped in the Patchouli 'test failed' error)
    public let test: TestHandler?

    public init(added: AddedHandler? = nil,
                replaced: ReplacedHandler? = nil,
                replace: ReplaceHandler? = nil,
                moved: MovedHandler? = nil,
                deleted: DeletedHandler? = nil,
                test: TestHandler? = nil) {

        self.added = added
        self.replaced = replaced
        self.replace = replace
        self.moved = moved
        self.deleted = deleted
        self.test = test
    }
}
