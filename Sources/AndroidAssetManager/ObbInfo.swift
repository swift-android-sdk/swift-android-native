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

// MARK: - ObbState

/// Status of an OBB mount/unmount operation, passed to the callback.
public enum ObbState: Int32, Sendable, CaseIterable {

    /// The OBB container was successfully mounted.
    case mounted = 1

    /// The OBB container was successfully unmounted.
    case unmounted = 2
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

internal typealias ObbStateResult = Result<ObbState, AndroidFileManagerError>

internal extension ObbStateResult {

    init(_ result: Int32) {
        if let state = ObbState(rawValue: result) {
            self = .success(state)
        } else {
            self = .failure(.obb(.init(rawValue: result)))
        }
    }
}
