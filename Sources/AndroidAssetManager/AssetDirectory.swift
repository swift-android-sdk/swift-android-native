//
//  AssetDirectory.swift
//  SwiftAndroid
//
//  Created by Alsey Coleman Miller on 2/27/26.
//

#if os(Android)
import Android
import CAndroidNDK
#endif

/// A handle to an `AAssetDir`.
///
/// Asset directory values own their pointer and close it during deinitialization.
public struct AssetDirectory: ~Copyable {

    internal let pointer: OpaquePointer

    internal init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }

    deinit {
        AAssetDir_close(pointer)
    }
}

// MARK: - Methods

public extension AssetDirectory {

    /// Returns the file name of the next asset in the directory, or `nil` when exhausted.
    mutating func next() -> String? {
        guard let cString = AAssetDir_getNextFileName(pointer) else {
            return nil
        }
        return String(cString: cString)
    }

    /// Resets the iteration to the beginning of the directory.
    mutating func rewind() {
        AAssetDir_rewind(pointer)
    }
}

// MARK: - Sequence

public extension AssetDirectory {
    
    /// A `Sequence` adapter over ``AssetDirectory`` for use in `for`-`in` loops.
    ///
    /// Iteration is single-pass; call ``rewind()`` to restart from the beginning.
    final class Sequence: Swift.Sequence, IteratorProtocol, @unchecked Sendable {

        public typealias Element = String

        private var directory: AssetDirectory
        
        public init(_ directory: consuming AssetDirectory) {
            self.directory = directory
        }

        public func next() -> String? {
            directory.next()
        }

        public func makeIterator() -> AssetDirectory.Sequence { self }
        
        /// Resets iteration to the beginning of the directory.
        public func rewind() {
            directory.rewind()
        }
    }
}
