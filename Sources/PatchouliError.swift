// Interesting: if you have src in different folders, xcode won't give compile errors
// about duplicate source filenames.

// open or final?

/// Note that for clarity, we name errors e,g. 'mutatingAdd...' and not 'added...'
public enum PatchouliError<T: PatchType>: Error {
    case mutatingAddNotSupported
    case mutatingRemoveNotSupported
    case mutatingReplaceNotSupported
    case mutatingMoveNotSupported
    case mutatingCopyNotSupported
    // NB 'test' doesn't alter the source content,
    // so it is called 'test' in both mutating and non-mutating worlds
    case testNotSupported
    case mutatingReduceNotSupported

    case testFailed(T.ContentType, T.AddressType, T.ContentType)
}
