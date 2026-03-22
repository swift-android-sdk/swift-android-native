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

    /// Error with OBB file.
    case obb(ObbErrorCode)
}

public extension AndroidFileManagerError {

    struct ObbErrorCode: RawRepresentable, Equatable, Sendable {

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// An internal error occurred during the operation.
        public static var `internal`: ObbErrorCode { ObbErrorCode(rawValue: 20) }

        /// The OBB container could not be mounted.
        public static var couldNotMount: ObbErrorCode { ObbErrorCode(rawValue: 21) }

        /// The OBB container could not be unmounted.
        public static var couldNotUnmount: ObbErrorCode { ObbErrorCode(rawValue: 22) }

        /// The OBB container is not currently mounted.
        public static var notMounted: ObbErrorCode { ObbErrorCode(rawValue: 23) }

        /// The OBB container is already mounted.
        public static var alreadyMounted: ObbErrorCode { ObbErrorCode(rawValue: 24) }

        /// The caller does not have permission to perform the operation.
        public static var permissionDenied: ObbErrorCode { ObbErrorCode(rawValue: 25) }
    }
}
