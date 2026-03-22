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

/// Android Obb File
public actor ObbFile {

    // MARK: - Properties

    public let path: String

    internal let manager: StorageManager

    // MARK: - Initialization

    public init(path: String) throws(AndroidFileManagerError) {
        self.path = path
        self.manager = try StorageManager()
    }

    // MARK: - Methods

    @discardableResult
    public func mount() async throws(AndroidFileManagerError) -> ObbState {
        try await manager.mountObb(path: path)
    }

    @discardableResult
    public func unmount() async throws(AndroidFileManagerError) -> ObbState {
        try await manager.unmountObb(path: path)
    }

    public var isMounted: Bool {
        manager.isObbMounted(path: path)
    }

    public var mountedPath: String? {
        manager.mountedObbPath(for: path)
    }
}
