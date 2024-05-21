
// MARK: - Reduce for PatchedContent

import Foundation

public extension PatchedContent {

    /// Convenience that calls reduce using the patchable for the PatchType (i.e. T)
    func reduced() throws -> T.ContentType {
        try reduced(T.patcher)
    }

    /// Returns the content produced by applying the patches to the content
    /// using the `patcher` protocol witness.
    /// To use the default patcher for a PatchType, please instead use the convenience `reduce()`.
    func reduced(_ patcher: Patchable<T>) throws -> T.ContentType {
        var accumulatedReduceResult = content

        for item in contentPatches {

            let targetContent = item.contentPatch

            switch item.patchSpec {

            case let .add(address):
                if let newContent = try targetContent?.reduced(patcher) {
                    guard let added = patcher.added else { throw PatchouliError<T>.witnessMissingAddedFunction }
                    accumulatedReduceResult = added(accumulatedReduceResult, newContent, address)
                }

            case let .replace(address):
                if let newContent = try targetContent?.reduced(patcher) {
                    guard let replaced = patcher.replaced else { throw PatchouliError<T>.witnessMissingReplaceFunction }
                    accumulatedReduceResult = replaced(accumulatedReduceResult, newContent, address)
                }

            case let .move(fromAddress, toAddress):
                guard let moved = patcher.moved else { throw PatchouliError<T>.witnessMissingMovedFunction }
                accumulatedReduceResult = moved(accumulatedReduceResult, fromAddress, toAddress)

            case let .delete(address):
                guard let removed = patcher.removed else { throw PatchouliError<T>.witnessMissingRemoveFunction }
                accumulatedReduceResult = removed(accumulatedReduceResult, address)

            case let .test(address):
                guard let test = patcher.test else { throw PatchouliError<T>.witnessMissingTestFunction }
                if !test(accumulatedReduceResult, address) { throw PatchouliError<T>.testFailed(address) }

            case .empty:
                break
            }
        }
        return accumulatedReduceResult
    }

    /// Convenience that calls reduce using the mutating patchable for the PatchType (i.e. T)
    mutating func reduce() throws -> Void {
        guard let mutatingPatcher = T.mutatingPatcher else {
            throw PatchouliError<T>.witnessMissingMutatingReduceFunction
        }
        try reduce(mutatingPatcher)
    }

    /// Returns the content produced by applying the patches to the content
    /// using the `patcher` protocol witness.
    /// To use the default patcher for a PatchType, please instead use the convenience `reduce()`.
    mutating func reduce(_ patcher: MutatingPatchable<T>) throws -> Void {
//        var accumulatedReduceResult = content

        for item in contentPatches {

            guard var targetContent = item.contentPatch else { return }

            switch item.patchSpec {

            case let .replace(address):
                try targetContent.reduce(patcher)
                guard let replace = patcher.replace else { throw PatchouliError<T>.witnessMissingReplaceFunction }
                replace(&content, targetContent.content, address)

            default:
                break
            }
        }
    }
}
