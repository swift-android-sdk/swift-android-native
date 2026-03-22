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

#if canImport(Android)
import Android
import CAndroidNDK
#endif

/// A sensor event containing a measurement from a hardware sensor.
public struct SensorEvent: Sendable {

    private let raw: ASensorEvent

    internal init(_ raw: ASensorEvent) {
        self.raw = raw
    }

    @inline(__always)
    internal func withRawDataBytes<R>(
        _ body: (UnsafeRawBufferPointer) -> R
    ) -> R {
        withUnsafeBytes(of: raw) { rawBytes in
            // ASensorEvent layout:
            // version(4) + sensor(4) + type(4) + reserved0(4) + timestamp(8) + data(64)
            let dataOffset = (MemoryLayout<Int32>.size * 4) + MemoryLayout<Int64>.size
            let dataStart = rawBytes.baseAddress!.advanced(by: dataOffset)
            let dataBytes = UnsafeRawBufferPointer(
                start: dataStart,
                count: MemoryLayout<Float>.size * 16
            )
            return body(dataBytes)
        }
    }
}

// MARK: - Properties

public extension SensorEvent {

    /// The sensor identifier (matches `Sensor.handle`).
    var sensor: Int32 { raw.sensor }

    /// The sensor type.
    var type: SensorType { SensorType(rawValue: raw.type) }

    /// The time at which the event occurred, in nanoseconds since boot.
    var timestamp: Int64 { raw.timestamp }

    /// Raw floating-point data values (up to 16 floats).
    ///
    /// The layout depends on `type`. For most sensors the relevant values
    /// are in the first 3 elements (x, y, z).
    var data: [Float] {
        withRawDataBytes { bytes in
            Array(bytes.bindMemory(to: Float.self))
        }
    }
}

// MARK: - Convenience Accessors

public extension SensorEvent {

    /// Acceleration vector in m/s² (x, y, z) — valid for `.accelerometer`,
    /// `.linearAcceleration`, and `.gravity` events.
    var acceleration: (x: Float, y: Float, z: Float) {
        withRawDataBytes { bytes in
            let f = bytes.bindMemory(to: Float.self)
            return (f[0], f[1], f[2])
        }
    }

    /// Rotation rate in rad/s (x, y, z) — valid for `.gyroscope` events.
    var angularVelocity: (x: Float, y: Float, z: Float) {
        withRawDataBytes { bytes in
            let f = bytes.bindMemory(to: Float.self)
            return (f[0], f[1], f[2])
        }
    }

    /// Magnetic field in μT (x, y, z) — valid for `.magneticField` events.
    var magneticField: (x: Float, y: Float, z: Float) {
        withRawDataBytes { bytes in
            let f = bytes.bindMemory(to: Float.self)
            return (f[0], f[1], f[2])
        }
    }

    /// Rotation vector (x, y, z, w) — valid for `.rotationVector` and
    /// related events.
    var rotationVector: (x: Float, y: Float, z: Float, w: Float) {
        withRawDataBytes { bytes in
            let f = bytes.bindMemory(to: Float.self)
            return (f[0], f[1], f[2], f[3])
        }
    }

    /// Illuminance in lx — valid for `.light` events.
    var light: Float {
        withRawDataBytes { $0.bindMemory(to: Float.self)[0] }
    }

    /// Distance in cm — valid for `.proximity` events.
    var distance: Float {
        withRawDataBytes { $0.bindMemory(to: Float.self)[0] }
    }

    /// Temperature in °C — valid for `.ambientTemperature` events.
    var temperature: Float {
        withRawDataBytes { $0.bindMemory(to: Float.self)[0] }
    }

    /// Pressure in hPa — valid for `.pressure` events.
    var pressure: Float {
        withRawDataBytes { $0.bindMemory(to: Float.self)[0] }
    }

    /// Relative humidity as a percentage — valid for `.relativeHumidity` events.
    var relativeHumidity: Float {
        withRawDataBytes { $0.bindMemory(to: Float.self)[0] }
    }

    /// Cumulative step count since last reboot — valid for `.stepCounter` events.
    var stepCount: UInt64 {
        withRawDataBytes { $0.bindMemory(to: UInt64.self)[0] }
    }

    /// Hinge angle in degrees — valid for `.hingeAngle` events.
    var hingeAngle: Float {
        withRawDataBytes { $0.bindMemory(to: Float.self)[0] }
    }
}
