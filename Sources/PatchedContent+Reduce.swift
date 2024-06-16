
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

        do {
            for item in contentPatches {

                let targetContent = item.contentPatch

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
        let originalContent = content

        for item in contentPatches {
            switch item.patchSpec {

            case let .add(address):
                guard var targetContent = item.contentPatch else { throw PatchouliError<T>.contentWasNil }

                try targetContent.reduce(patcher)

                guard let add = patcher.add else { throw PatchouliError<T>.mutatingAddNotSupported }
                add(&content, targetContent.content, address)

            case let .remove(address):
                guard let remove = patcher.remove else { throw PatchouliError<T>.mutatingRemoveNotSupported }
                remove(&content, address)

            case let .replace(address):
                guard var targetContent = item.contentPatch else { throw PatchouliError<T>.contentWasNil }

                try targetContent.reduce(patcher)

                guard let replace = patcher.replace else { throw PatchouliError<T>.mutatingReplaceNotSupported }
                replace(&content, targetContent.content, address)

            case let .move(fromAddress, toAddress):
                guard let move = patcher.move else { throw PatchouliError<T>.mutatingMoveNotSupported }
                move(&content, fromAddress, toAddress)

            case let .test(expectedContent, address):
                guard let test = patcher.test else { throw PatchouliError<T>.testNotSupported }

                do {
                    try test(content, expectedContent, address)
                }
                catch let error as PatchouliError<T> {
                    switch error {
                    case .testFailed:
                        content = originalContent
                    default:
                        break
                    }
                }

            default:
                break
            }
        }
    }
}
