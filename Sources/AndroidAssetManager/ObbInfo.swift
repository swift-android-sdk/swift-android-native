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

// MARK: - ObbState

/// Status of an OBB mount/unmount operation, passed to the callback.
public enum ObbState: Int32, Sendable {

    /// The OBB container was successfully mounted.
    case mounted = 1

    /// The OBB container was successfully unmounted.
    case unmounted = 2

    /// An internal error occurred during the operation.
    case errorInternal = 20

    /// The OBB container could not be mounted.
    case errorCouldNotMount = 21

    /// The OBB container could not be unmounted.
    case errorCouldNotUnmount = 22

    /// The OBB container is not currently mounted.
    case errorNotMounted = 23

    /// The OBB container is already mounted.
    case errorAlreadyMounted = 24

    /// The caller does not have permission to perform the operation.
    case errorPermissionDenied = 25
}

// MARK: - ObbInfoFlags

/// Flags describing an OBB file, as returned by `ObbInfo.flags`.
public struct ObbInfoFlags: OptionSet, Sendable {

    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    /// The OBB is an overlay patch OBB.
    public static var overlay: ObbInfoFlags { ObbInfoFlags(rawValue: 0x0001) }
}

// MARK: - ObbInfo

/// Information about an OBB file, obtained via `ObbScanner.obbInfo(at:)`.
public struct ObbInfo: ~Copyable {

    private let pointer: OpaquePointer

    internal init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }

    public init?(path: String) {
        guard let pointer = AObbScanner_getObbInfo(path) else {
            return nil
        }
        self.init(pointer)
    }

    deinit {
        AObbInfo_delete(pointer)
    }
}

public extension ObbInfo {

    /// The flags for this OBB.
    var flags: ObbInfoFlags {
        ObbInfoFlags(rawValue: AObbInfo_getFlags(pointer))
    }

    /// The package name of this OBB.
    var packageName: String? {
        AObbInfo_getPackageName(pointer).map { String(cString: $0) }
    }

    /// The version number of this OBB.
    var version: Int32 {
        AObbInfo_getVersion(pointer)
    }
}
