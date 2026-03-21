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
    mutating func nextFileName() -> String? {
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
