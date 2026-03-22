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

/// Android Sensor Error
public enum AndroidSensorError: Swift.Error {

    /// Unable to get sensor manager instance.
    case invalidManager

    /// Unable to create event queue.
    case createEventQueue

    /// Unable to enable sensor (result code).
    case enableSensor(Int32)

    /// Unable to disable sensor (result code).
    case disableSensor(Int32)

    /// Unable to register sensor (result code).
    case registerSensor(Int32)

    /// Unable to set event rate (result code).
    case setEventRate(Int32)

    /// Error reading sensor events (result code).
    case getEvents(Int32)
}
