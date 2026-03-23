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
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/**
 * Listens for when an `AndroidBinder` dies.
 *
 * This can be used to get a notification when a remote process hosting an `AndroidBinder`
 * is killed or crashes. Register with `AndroidBinder.linkToDeath(_:cookie:)`.
 *
 * Available since API level 29.
 */
@available(Android 29, *)
public final class DeathRecipient {

    internal let handle: Handle

    internal init(_ handle: Handle) {
        self.handle = handle
    }

    deinit {
        handle.delete()
    }
}

// MARK: - Initialization

@available(Android 29, *)
public extension DeathRecipient {

    /// Directly initialize from a pointer.
    convenience init(_ pointer: OpaquePointer) {
        self.init(Handle(pointer))
    }

    /**
     * Creates a new death recipient.
     *
     * Available since API level 29.
     *
     * \param onDied called when the associated binder dies. The `cookie` argument
     *   is the value passed to `AndroidBinder.linkToDeath(_:cookie:)`.
     * \return a new death recipient, or `nil` on allocation failure.
     */
    convenience init?(onDied: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) {
        guard let handle = Handle.create(onDied: onDied) else {
            return nil
        }
        self.init(handle)
    }
}

// MARK: - Methods

@available(Android 29, *)
public extension DeathRecipient {

    /**
     * Sets a callback that is invoked whenever this recipient is unlinked from a binder,
     * whether because the binder died or because `unlinkToDeath` was called explicitly.
     *
     * Available since API level 33.
     *
     * \param onUnlinked called when this recipient is unlinked. The `cookie` argument
     *   is the value that was passed to `AndroidBinder.linkToDeath(_:cookie:)`.
     */
    @available(Android 33, *)
    func setOnUnlinked(_ onUnlinked: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) {
        handle.setOnUnlinked(onUnlinked)
    }
}

// MARK: - Supporting Types

@available(Android 29, *)
internal extension DeathRecipient {

    struct Handle {

        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }
}

@available(Android 29, *)
internal extension DeathRecipient.Handle {

    static func create(onDied: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) -> DeathRecipient.Handle? {
        AIBinder_DeathRecipient_new(onDied).map { .init($0) }
    }

    func delete() {
        AIBinder_DeathRecipient_delete(pointer)
    }

    @available(Android 33, *)
    func setOnUnlinked(_ onUnlinked: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) {
        AIBinder_DeathRecipient_setOnUnlinked(pointer, onUnlinked)
    }
}
