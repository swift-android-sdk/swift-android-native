//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAndroidNative open source project
//
// Copyright (c) 2024-2026 Skip.dev and SwiftAndroidNative project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAndroidNative project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if os(Android)
import Android
import CAndroidNDK
#endif

/// Wrapper around Android `AAssetManager`.
public struct AssetManager: @unchecked Sendable {

    internal let pointer: OpaquePointer

    /// Creates a manager from an existing native pointer.
    public init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }
}

// MARK: - Methods

public extension AssetManager {

    /// Opens an asset by path.
    ///
    /// - Parameters:
    ///   - path: Relative path under the APK `assets/` directory.
    ///   - mode: Access hint for Android's asset backend.
    func open(_ path: String, mode: AssetMode = .streaming) throws(AndroidFileManagerError) -> Asset {
        guard let pointer = path.withCString({
            AAssetManager_open(pointer, $0, mode.rawValue)
        }) else {
            throw .openAsset(path)
        }
        return Asset(pointer)
    }

    /// Opens a directory for iteration over its asset file names.
    ///
    /// - Parameter path: Relative path under the APK `assets/` directory. Pass `""` for the root.
    func openDirectory(_ path: String) throws(AndroidFileManagerError) -> AssetDirectory {
        guard let pointer = path.withCString({
            AAssetManager_openDir(pointer, $0)
        }) else {
            throw .openAssetDirectory(path)
        }
        return AssetDirectory(pointer)
    }
}

// MARK: - Supporting Types

public extension AssetManager {

    /// `AAssetManager_open` mode flags.
    enum AssetMode: Int32, Sendable {
        case unknown = 0
        case random = 1
        case streaming = 2
        case buffer = 3
    }
}

