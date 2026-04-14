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

import Testing
import AndroidHardware
#if canImport(OSLog)
import OSLog // note: on non-android platforms, this will just export the system OSLog
#else
import AndroidLogging
#endif

#if os(Android)
let android = true
#else
let android = false
#endif

@Suite(.enabled(if: android))
struct AndroidHardwareTests {

    let packageName = "org.swift.test.swift_android_native"

    @Test func testSensorManagerInit() {
        let logger = Logger(subsystem: "AndroidHardwareTests", category: "testSensorManagerInit")
        // SensorManager requires a real Android device; on other platforms the
        // NDK stub returns nil and init fails.
        let manager = SensorManager(package: packageName)
        logger.log("Found manager: \(manager != nil)")
    }

    @Test func testListSensors() {
        guard let manager = SensorManager(package: packageName) else {
            // Not running on Android — nothing to enumerate.
            return
        }
        let logger = Logger(subsystem: "AndroidHardwareTests", category: "testListSensors")

        let sensors = manager.sensors
        // There should be at least one sensor on any real Android device.
        #expect(!sensors.isEmpty)

        for (index, sensor) in sensors.enumerated() {
            // Every sensor must have a non-empty name and vendor string.
            logger.log("\(index + 1). \(sensor.name) (\(sensor.type.rawValue))")
            #expect(!sensor.name.isEmpty)
            #expect(!sensor.vendor.isEmpty)
        }
    }

    @Test func testDefaultSensor() {
        guard let manager = SensorManager(package: packageName) else {
            return
        }

        // Accelerometer is present on every Android device.
        let accelerometer = manager.defaultSensor(type: .accelerometer)
        #expect(accelerometer != nil)

        if let sensor = accelerometer {
            #expect(sensor.type == .accelerometer)
            #expect(!sensor.name.isEmpty)
        }
    }

    @Test func testDefaultSensorWakeUp() {
        guard let manager = SensorManager(package: packageName) else {
            return
        }

        // Non-wake-up accelerometer must exist; wake-up variant is optional.
        let nonWakeUp = manager.defaultSensor(type: .accelerometer, wakeUp: false)
        #expect(nonWakeUp != nil)

        if let sensor = nonWakeUp {
            #expect(!sensor.isWakeUpSensor)
        }
    }

    @Test func testSensorProperties() {
        guard let manager = SensorManager(package: packageName) else {
            return
        }

        guard let sensor = manager.defaultSensor(type: .accelerometer) else {
            return
        }

        // Resolution and delay must be reasonable values.
        #expect(sensor.resolution > 0)
        #expect(sensor.minDelay >= 0)
        #expect(sensor.fifoMaxEventCount >= sensor.fifoReservedEventCount)
    }
}
