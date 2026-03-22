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

/// An actor that manages the lifecycle of an Android OBB (Opaque Binary Blob) container.
///
/// OBB files are used to distribute large assets alongside an Android application.
/// Use `ObbFile` to mount and unmount an OBB container at a given path.
///
/// ```swift
/// let obb = try ObbFile(path: "/path/to/main.obb")
/// try await obb.mount()
/// // Access assets at obb.mountedPath
/// try await obb.unmount()
/// ```
public actor ObbFile {

    // MARK: - Properties

    /// The path to the OBB file on disk.
    public let path: String

    internal let manager: StorageManager

    // MARK: - Initialization

    public init(path: String) throws(AndroidFileManagerError) {
        self.path = path
        self.manager = try StorageManager()
    }

    // MARK: - Methods

    /// Mounts the OBB container, returning the resulting `ObbState`.
    ///
    /// - Returns: `.mounted` on success.
    /// - Throws: `AndroidFileManagerError.obb` if the mount operation fails.
    @discardableResult
    public func mount() async throws(AndroidFileManagerError) -> ObbState {
        try await manager.mountObb(path: path)
    }

    /// Unmounts the OBB container, returning the resulting `ObbState`.
    ///
    /// - Returns: `.unmounted` on success.
    /// - Throws: `AndroidFileManagerError.obb` if the unmount operation fails.
    @discardableResult
    public func unmount() async throws(AndroidFileManagerError) -> ObbState {
        try await manager.unmountObb(path: path)
    }

    /// Whether the OBB container is currently mounted.
    public var isMounted: Bool {
        manager.isObbMounted(path: path)
    }

    /// The path at which the OBB container is mounted, or `nil` if it is not mounted.
    public var mountedPath: String? {
        manager.mountedObbPath(for: path)
    }
}
