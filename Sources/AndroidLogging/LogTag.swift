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

/// Android Log Tag
public struct LogTag: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let rawValue: String

    public init(rawValue: String) {
        assert(rawValue.isEmpty == false)
        self.rawValue = rawValue
    }
}

// MARK: - CustomStringConvertible

extension LogTag: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

// MARK: - ExpressibleByStringLiteral

extension LogTag: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
