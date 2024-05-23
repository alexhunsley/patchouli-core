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
        // 'copied' doesn't really make sense, so omitted
        //    copied: {
        moved: { (container: String, fromAddress: String, toAddress: String) -> String in
            container
                // the order here is crucial
                .replacingOccurrences(of: fromAddress, with: "")
                .replacingOccurrences(of: toAddress, with: fromAddress)
        },
        // we don't care about the expectedContent, it's just the address for this string patcher
        test: { (container: String, _: String, address: String) in
            container.contains(address)
        }
        // Note that we provide no 'move' implementation as it has no obvious meaning for string matching
    )

    public static var mutatingPatcher: MutatingPatchable<StringPatchType>? = .init(
        add: { (container: inout String, address: String, content: String) in
            // We interpret 'add' in string matching to mean "place a copy of content
            // before every occurence of the address".
            // if the address isn't found in the string, we don't care.
            //
            // Value types like strings can't actually be
            // mutated in-place so this is as close as we get:
            // assigning. Same end result as far as caller who
            // passes us the inout param, though.
            container = container.prefixing(address, with: content)
        },
        remove: { (container: inout String, address: String) in
            container = container.replacingOccurrences(of: address, with: "")
        },
        replace: { (container: inout String, replacement: String, address: String) in
            container = container.replacingOccurrences(of: address, with: replacement)
        },
        // 'copied' doesn't really make sense, so omitted
        //    copied: {
        move: { (container: inout String, fromAddress: String, toAddress: String) in
            container = container
                // the order here is crucial
                .replacingOccurrences(of: fromAddress, with: "")
                .replacingOccurrences(of: toAddress, with: fromAddress)
        },
        // NB lasdt param not used for strings as doesn't make sense
        test: { (container: String, expectedContent: String, address: String) -> Bool in
//        expectedContentDummy: String) -> Bool in
            container.contains(address)
        }
    )
}
