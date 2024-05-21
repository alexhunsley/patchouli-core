import Foundation

public typealias PatchedString = PatchedContent<StringPatchType>
public typealias StringPatchItem = AddressedPatch<StringPatchType>
public typealias StringPatchList = [StringPatchItem]

public struct StringPatchType: PatchType {
    public typealias ContentType = String
    public typealias AddressType = String

    public static var emptyContent = ""

    /// The Protocol Witness used by the reducer
    static public let patcher = Patchable<StringPatchType>(
        added: { (container: String, address: String, content: String) -> String in
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
        // 'copied' doesn't really make sense.
        // 'moved' doesn't really make sense.
        test: { (container: String, address: String) in
            container.contains(address)
        }
        // Note that we provide no 'move' implementation as it has no obvious meaning for string matching
    )

    public static var mutatingPatcher: MutatingPatchable<StringPatchType>? = .init(
        added: { (container: inout String, address: String, content: String) in
            // We interpret 'add' in string matching to mean "place a copy of content
            // before every occurence of the address".
            // if the address isn't found in the string, we don't care.
            container = container.prefixing(address, with: content)
        },
        removed: { (container: inout String, address: String) in
            container = container.replacingOccurrences(of: address, with: "")
        },
        replace: { (container: inout String, replacement: String, address: String) in
            container = container.replacingOccurrences(of: address, with: replacement)
        }
        // 'copy' doesn't really make sense.
        // 'move' doesn't really make sense.
    )
}
