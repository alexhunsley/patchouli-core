/// Note that for clarity, we name errors e,g. 'mutatingAdd...' and not 'added...'
public enum PatchouliError<T: PatchType>: Error {
    case mutatingAddNotSupported
    case mutatingRemoveNotSupported
    case mutatingReplaceNotSupported
    case mutatingMoveNotSupported
    case mutatingCopyNotSupported
    case addNotSupported
    case removeNotSupported
    case replaceNotSupported
    case moveNotSupported
    case copyNotSupported
    case testNotSupported
    case mutatingReduceNotSupported
    case contentWasNil

    case testFailed(T.ContentType, T.AddressType, T.ContentType)
}
