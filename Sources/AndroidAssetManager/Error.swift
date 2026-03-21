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

/// Android file manager error.
public enum AndroidFileManagerError: Swift.Error, Equatable, Sendable {

    /// Unable to initialize an `AConfiguration` instance.
    case invalidConfiguration

    /// Unable to initialize an `AStorageManager` instance.
    case invalidStorageManager

    /// Unable to open asset at the specified path.
    case openAsset(String)

    /// Unable to open asset directory at the specified path.
    case openAssetDirectory(String)

    /// Error reading asset bytes (result code).
    case readAsset(Int32)

    /// Error seeking within asset (result code).
    case seekAsset(Int64)

    /// Error mounting OBB file (result code).
    case mountObb(Int32)

    /// Error unmounting OBB file (result code).
    case unmountObb(Int32)
}
