// Interesting: if you have src in different folders, xcode won't give compile errors
// about duplicate source filenames.

// open or final?

public enum PatchouliError<T: PatchType>: Error {
    // TODO remove 'witness' from these messages? It's an impl detail
    // a user probably doesn't care about
    case witnessMissingReplaceFunction
    case witnessMissingAddedFunction
    case witnessMissingMovedFunction
    case witnessMissingDeleteFunction
    case witnessMissingTestFunction
    case witnessMissingReduceFunction

    case testFailed(T.AddressType)
}
