
// MARK: - Reduce for PatchedContent

import Foundation

public extension PatchedContent {

    /// Convenience that calls reduce using the patchable for the PatchType (i.e. T)
    func reduced() throws -> T.ContentType {
        try reduced(T.patcher)
    }

//    func doSomething<A, B, T>(with value: T) where T: MyType<A, B> {
// hmm thorny. Might be better after all working with usual PatchType, and adding on additional bit for the final reduce!

    // Hmmm.
    func reduced<P, TSP, PT, TSPT>(_ reducer: CoreReducer<P, TSP>) throws -> T.ContentType where P: Patchable<PT>, TSP: TwoStagePatchable<TSPT> {
        switch reducer {
        case .oneStage:
            break
        case .twoStage:
            break
        }
    }

    /// Returns the content produced by applying the patches to the content
    /// using the `patcher` protocol witness.
    /// To use the default patcher for a PatchType, please instead use the convenience `reduced()`.
    func reducedOneStage(_ patcher: Patchable<T>) throws -> T.ContentType {
        var accumulatedReduceResult = content

        do {
            for item in contentPatches {

                let targetContent = item.contentPatch

                switch item.patchSpec {

                case let .add(address):
                    if let newContent = try targetContent?.reduced(patcher) {
                        guard let added = patcher.added else { throw PatchouliError<T>.addNotSupported }
                        try accumulatedReduceResult = added(accumulatedReduceResult, newContent, address)
                    }

                case let .remove(address):
                    guard let removed = patcher.removed else { throw PatchouliError<T>.removeNotSupported }
                    try accumulatedReduceResult = removed(accumulatedReduceResult, address)

                case let .replace(address):
                    if let newContent = try targetContent?.reduced(patcher) {
                        guard let replaced = patcher.replaced else { throw PatchouliError<T>.replaceNotSupported }
                        try accumulatedReduceResult = replaced(accumulatedReduceResult, newContent, address)
                    }

                case let .copy(fromAddress, toAddress):
                    guard let copied = patcher.copied else { throw PatchouliError<T>.copyNotSupported }
                    try accumulatedReduceResult = copied(accumulatedReduceResult, fromAddress, toAddress)

                case let .move(fromAddress, toAddress):
                    guard let moved = patcher.moved else { throw PatchouliError<T>.moveNotSupported }
                    try accumulatedReduceResult = moved(accumulatedReduceResult, fromAddress, toAddress)

                case let .test(expectedContent, address):
                    guard let test = patcher.test else { throw PatchouliError<T>.testNotSupported }
                    try accumulatedReduceResult = test(accumulatedReduceResult, expectedContent, address)
                case .empty:
                    break
                }
            }
        }
        catch let error as PatchouliError<T> {
            switch error {
            case .testFailed:
                // Per JSON Patch spec, if a test op fails we just return the original content
                return content
            default:
                throw error
            }
        }
        return accumulatedReduceResult
    }
}
