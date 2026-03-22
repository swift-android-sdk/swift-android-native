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

public extension Permission {

    struct Group: RawRepresentable, Equatable, Hashable, Codable, Sendable {

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public extension Permission.Group {

    static let calendar = Permission.Group(rawValue: "android.permission-group.CALENDAR")

    static let callLog = Permission.Group(rawValue: "android.permission-group.CALL_LOG")

    static let camera = Permission.Group(rawValue: "android.permission-group.CAMERA")

    static let contacts = Permission.Group(rawValue: "android.permission-group.CONTACTS")

    static let location = Permission.Group(rawValue: "android.permission-group.LOCATION")

    static let microphone = Permission.Group(rawValue: "android.permission-group.MICROPHONE")

    static let phone = Permission.Group(rawValue: "android.permission-group.PHONE")

    static let sensors = Permission.Group(rawValue: "android.permission-group.SENSORS")

    static let sms = Permission.Group(rawValue: "android.permission-group.SMS")

    static let storage = Permission.Group(rawValue: "android.permission-group.STORAGE")
}
