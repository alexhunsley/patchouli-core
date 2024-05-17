///
/// Fundamental types describing patch content.
/// Everything in here is generic.

import Foundation

public typealias PatchListProducer<T: PatchType> = () -> [AddressedPatch<T>]

/// The kind of information we're patching, and how to patch it.
/// You can make your own PatchType conformances (see e.g. StringPatchType for an example).
public protocol PatchType {
    associatedtype ContentType
    associatedtype AddressType

    static var emptyContent: ContentType { get }

    /// A Patchable protcol witness, used by the reducer
    static var patcher: Patchable<Self> { get }

    // the in-place patcher is optional
    static var inPlacePatcher: InPlacePatchable<Self>? { get }
}

extension PatchType {
    // nil conformance as default for the in-place patcher (means none provided)
    public static var inPlacePatcher: InPlacePatchable<Self>? { nil }
}

// Once is very similar to Never, but it has one accessible
// instance (and cannot be inited).
public enum Once {
    case once

    private init() { self = .once }
    public static let instance = Once()
}

/// used as a dummy in tests
public struct DummyPatchType: PatchType {
    public typealias ContentType = Once
    public typealias AddressType = Never

    public static var emptyContent: ContentType { Once.once }

    // The Never patch provides no functions
    public static var patcher = Patchable<DummyPatchType>()
    public static var inPlacePatcher = InPlacePatchable<DummyPatchType>()
}

// -----------------------------------------------------------------

/// This generic PatchSpec's design is based on JSONPatch's operations.
public enum PatchSpec<T: PatchType> {
    public typealias A = T.AddressType

    case add(A)
    case replace(A)
    case move(A, A)
    case delete(A)
    case test(A)

    // helper for handling optional entries in patch list
    case empty
}

/// Content that has zero-to-many patches
public struct PatchedContent<T: PatchType> {
    public typealias C = T.ContentType

    var content: C
    let contentPatches: [AddressedPatch<T>]

    public init(content: C, contentPatches: [AddressedPatch<T>] = .init()) {
        self.content = content
        self.contentPatches = contentPatches
    }
}

/// Patch that targets an address
public struct AddressedPatch<T: PatchType> {

    let patchSpec: PatchSpec<T>
    let contentPatch: PatchedContent<T>?

    init(patchSpec: PatchSpec<T>, contentPatch: PatchedContent<T>? = nil) {
        self.patchSpec = patchSpec
        self.contentPatch = contentPatch
    }

    public var isEmpty: Bool {
        if case .empty = patchSpec {
            return true
        }
        return false
    }

    public static var emptyPatchList: [AddressedPatch<T>] { .init() }
    public static var empty: AddressedPatch<T> { .init(patchSpec: .empty) }
}
