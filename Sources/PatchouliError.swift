public enum PatchouliError<T: PatchType>: Error {
    case addNotSupported
    case removeNotSupported
    case replaceNotSupported
    case moveNotSupported
    case copyNotSupported
    case testNotSupported
    case contentWasNil

    case testFailed(T.ContentType, T.AddressType, T.ContentType)
}

