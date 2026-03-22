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
import AndroidLooper

/// Manages access to the device's hardware sensors.
///
/// Obtain an instance via ``init(package:)``, then enumerate available sensors
/// or create event queues for receiving data.
public struct SensorManager: @unchecked Sendable {

    internal let pointer: OpaquePointer

    internal init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }
}

// MARK: - Initialization

public extension SensorManager {

    /// Returns the sensor manager for the given package name.
    ///
    /// - Parameter package: The package name of the calling application
    ///   (e.g. `"com.example.myapp"`).
    init?(package: String) {
        guard let pointer = package.withCString({ ASensorManager_getInstanceForPackage($0) }) else {
            return nil
        }
        self.init(pointer)
    }
}

// MARK: - Sensors

public extension SensorManager {

    /// Returns all sensors available on the device.
    var sensors: [Sensor] {
        var list: UnsafePointer<OpaquePointer?>?
        let count = ASensorManager_getSensorList(pointer, &list)
        guard count > 0, let list else { return [] }
        return (0..<Int(count)).compactMap { index in
            guard let pointer = list[index] else { return nil }
            return Sensor(pointer)
        }
    }

    /// Returns the default sensor of the given type, or `nil` if none exists.
    func defaultSensor(type: SensorType) -> Sensor? {
        ASensorManager_getDefaultSensor(pointer, type.rawValue).map { Sensor($0) }
    }

    /// Returns the default sensor of the given type with optional wake-up support.
    ///
    /// - Parameters:
    ///   - type: The sensor type.
    ///   - wakeUp: Pass `true` to request a wake-up sensor variant.
    func defaultSensor(type: SensorType, wakeUp: Bool) -> Sensor? {
        ASensorManager_getDefaultSensorEx(pointer, type.rawValue, wakeUp).map { Sensor($0) }
    }
}

// MARK: - Event Queue

public extension SensorManager {

    /// Creates an event queue associated with the given looper.
    ///
    /// Events will be delivered to `callback` (if non-nil) on the looper's
    /// thread; otherwise your code must call `SensorEventQueue.getEvents()`
    /// in response to looper activity signalled on `ident`.
    ///
    /// - Parameters:
    ///   - looper: The looper that will receive sensor events.
    ///   - ident: Identifier returned by `ALooper_pollOnce` when events are
    ///     available and `callback` is `nil`. Must be ≥ 0 in that case.
    ///   - callback: Optional C callback invoked on each event batch.
    ///   - data: User data pointer passed to `callback`.
    func createEventQueue(
        looper: borrowing Looper,
        ident: Int32 = 0,
        callback: ALooper_callbackFunc? = nil,
        data: UnsafeMutableRawPointer? = nil
    ) throws(AndroidSensorError) -> SensorEventQueue {
        let queuePointer = looper.withUnsafePointer { looperPtr in
            ASensorManager_createEventQueue(pointer, looperPtr, ident, callback, data)
        }
        guard let queuePointer else {
            throw .createEventQueue
        }
        return SensorEventQueue(queue: queuePointer, manager: pointer)
    }
}
