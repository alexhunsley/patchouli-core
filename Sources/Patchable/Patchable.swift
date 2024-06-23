import Foundation

/// The notocol ('not a protocol') for our patcher protocol witnesses.
/// Note the gerund style name ('-ing', '-able', etc) -- when we see this on
/// a struct, this is a hint that it's a notocol.
///
/// Protocol witness instantiations of this type should lose the
/// gerund style and be named e.g. 'patcher'.
///

// Thought: the one stage patcher is a specialisation of this with I = C.
// Let's just have one patchable, that has stage 1 content type.
// in simple reducer, that is the same as C (OR set to Never?)
// in 2 stage reducers, it is a diff type.
public struct Patchable<T: PatchType> {
    public typealias C = T.ContentType
    public typealias I = T.EncodedContentType
    public typealias A = T.AddressType

    public typealias AddedHandler = @Sendable (C?, C, A) throws -> I
    public typealias RemovedHandler = @Sendable (C?, A) throws -> I
    public typealias ReplacedHandler = @Sendable (C?, C, A) throws -> I
    public typealias CopiedHandler = @Sendable (C?, A, A) throws -> I
    public typealias MovedHandler = @Sendable (C?, A, A) throws -> I
    public typealias TestHandler = @Sendable (C?, C, A) throws -> I

    public typealias ListCombiner = @Sendable ([I]) throws -> C

    public let added: AddedHandler?
    public let removed: RemovedHandler?
    public let replaced: ReplacedHandler?
    public let copied: CopiedHandler?
    public let moved: MovedHandler?
    public let test: TestHandler?

    public let listCombiner: ListCombiner?

    public init(added: AddedHandler? = nil,
                removed: RemovedHandler? = nil,
                replaced: ReplacedHandler? = nil,
                copied: CopiedHandler? = nil,
                moved: MovedHandler? = nil,
                test: TestHandler? = nil,
                listCombiner: ListCombiner? = nil) {

        self.added = added
        self.removed = removed
        self.replaced = replaced
        self.copied = copied
        self.moved = moved
        self.test = test

        self.listCombiner = listCombiner
    }
}
