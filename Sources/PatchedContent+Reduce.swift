
// MARK: - Reduce for PatchedContent

import Foundation

public extension PatchedContent {

    /// Convenience that calls reduce using the patchable for the PatchType (i.e. T)
    /// TODO  ~~~this could actually be a calculated property (no params to give). Is that wise tho'?~~~
    ///     --- no, it throws, so must be a func.
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

            print("Processing patch: \(item)")
            switch item.patchSpec {

            case let .add(address):
                if let newContent = try targetContent?.reduced(patcher) {
                    guard let added = patcher.added else { throw PatchouliError<T>.addNotSupported }
                    print("new content, address = \(newContent), \(address)")
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
                if try !test(accumulatedReduceResult, expectedContent, address) {
                    throw PatchouliError<T>.testFailed(accumulatedReduceResult, address, expectedContent)
                }

            case .empty:
                break
            }
        }
        return accumulatedReduceResult
    }

    /// Convenience that calls reduce using the mutating patchable for the PatchType (i.e. T)
    mutating func reduce() throws -> Void {
        guard let mutatingPatcher = T.mutatingPatcher else {
            throw PatchouliError<T>.mutatingReduceNotSupported
        }
        try reduce(mutatingPatcher)
    }

    /// Returns the content produced by applying the patches to the content
    /// using the `patcher` protocol witness.
    /// To use the default patcher for a PatchType, please instead use the convenience `reduce()`.
    mutating func reduce(_ patcher: MutatingPatchable<T>) throws -> Void {
//        var accumulatedReduceResult = content

        for item in contentPatches {

            // dodo. Some actions can legitimately have no targetContent!
//            guard var targetContent = item.contentPatch else {
//                return
//            }

            switch item.patchSpec {

            // TODO other actions!
            case let .add(address):
                guard var targetContent = item.contentPatch else { throw PatchouliError<T>.contentWasNil }

                try targetContent.reduce(patcher)

                guard let add = patcher.add else { throw PatchouliError<T>.mutatingAddNotSupported }
                add(&content, targetContent.content, address)

            case let .remove(address):
                // there's no target content for a remove
//                try targetContent.reduce(patcher)
                guard let remove = patcher.remove else { throw PatchouliError<T>.mutatingRemoveNotSupported }
                print("ALAL before remove: \(content)")
                remove(&content, address)
                print("ALAL after remove: \(content)")

            case let .replace(address):
                guard var targetContent = item.contentPatch else { throw PatchouliError<T>.contentWasNil }

                try targetContent.reduce(patcher)

                guard let replace = patcher.replace else { throw PatchouliError<T>.mutatingReplaceNotSupported }
                replace(&content, targetContent.content, address)

            case let .move(fromAddress, toAddress):
//                try targetContent.reduce(patcher)
                guard let move = patcher.move else { throw PatchouliError<T>.mutatingMoveNotSupported }
                move(&content, fromAddress, toAddress)

            case let .test(expectedContent, address):
                guard let test = patcher.test else { throw PatchouliError<T>.testNotSupported }
                if !test(content, expectedContent, address) {
                    throw PatchouliError<T>.testFailed(content, address, expectedContent)
                }

            default:
                break
            }
        }
    }
}
