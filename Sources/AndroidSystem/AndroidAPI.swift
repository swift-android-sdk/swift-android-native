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
@_implementationOnly import CAndroidNDK
#endif

/// Android API Level
public struct AndroidAPI: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let rawValue: Int32

    public init(rawValue: Int32) {
        assert(rawValue > 0)
        self.rawValue = rawValue
    }
}

public extension AndroidAPI {

    /// Available since API level 24. Returns the API level of the device we're actually running on.
    @available(Android 24, *)
    static func ndkValue() -> AndroidAPI? {
        #if os(Android) && canImport(CAndroidNDK)
        let value = android_get_device_api_level()
        #else
        let value: Int32 = -1
        #endif
        guard value != -1 else {
            return nil
        }
        return .init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension AndroidAPI: CustomStringConvertible {

    public var description: String {
        rawValue.description
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension AndroidAPI: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int32) {
        self.init(rawValue: value)
    }
}
