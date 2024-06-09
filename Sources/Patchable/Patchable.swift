import Foundation

/// The notocol ('not a protocol') for our patcher protocol witnesses.
/// Note the gerund style name ('-ing', '-able', etc) -- when we see this on
/// a struct, this is a hint that it's a notocol.
///
/// Protocol witness instantiations of this type should lose the
/// gerund style and be named e.g. 'patcher'.
public struct Patchable<T: PatchType> {
    public typealias C = T.ContentType
    public typealias A = T.AddressType

    public typealias AddedHandler = @Sendable (C, C, A) throws -> C
    public typealias RemovedHandler = @Sendable (C, A) throws -> C
    public typealias ReplacedHandler = @Sendable (C, C, A) throws -> C
    public typealias CopiedHandler = @Sendable (C, A, A) throws -> C
    public typealias MovedHandler = @Sendable (C, A, A) throws -> C
    public typealias TestHandler = @Sendable (C, C, A) throws -> C
    
    public let added: AddedHandler?
    public let removed: RemovedHandler?
    public let replaced: ReplacedHandler?
    public let copied: CopiedHandler?
    public let moved: MovedHandler?
    // We may eventually want to make this throw (and return Void)
    // in order to let PatchType writers give error information
    // (would be wrapped in the Patchouli 'test failed' error)
    public let test: TestHandler?

    public init(added: AddedHandler? = nil,
                removed: RemovedHandler? = nil,
                replaced: ReplacedHandler? = nil,
                copied: CopiedHandler? = nil,
                moved: MovedHandler? = nil,
                test: TestHandler? = nil) {

        self.added = added
        self.removed = removed
        self.replaced = replaced
        self.copied = copied
        self.moved = moved
        self.test = test
    }
}
