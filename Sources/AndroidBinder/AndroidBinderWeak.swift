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
import Gblic
#endif

/**
 * A weak reference to an `AndroidBinder`.
 *
 * Weak references do not prevent the binder from being destroyed. They can be promoted
 * to a strong reference via `promote()`, which returns `nil` if the binder has been destroyed.
 *
 * Available since API level 29.
 */
@available(Android 29, *)
public struct AndroidBinderWeak: ~Copyable {

    internal let handle: Handle

    internal init(_ handle: Handle) {
        self.handle = handle
    }

    deinit {
        handle.delete()
    }
}

// MARK: - Initialization

public extension AndroidBinderWeak {

    /// Directly initialize from a pointer.
    init(_ pointer: OpaquePointer) {
        self.handle = .init(pointer)
    }

    /**
     * Creates a weak reference to the given binder.
     *
     * Available since API level 29.
     *
     * \param binder the binder to create a weak reference to.
     * \return a weak reference, or nil on allocation failure.
     */
    init?(_ binder: AndroidBinder) {
        guard let handle = Handle.create(from: binder) else {
            return nil
        }
        self.init(handle)
    }
}

// MARK: - Methods

public extension AndroidBinderWeak {

    /**
     * Attempts to promote this weak reference to a strong reference.
     *
     * Available since API level 29.
     *
     * \return the binder if it is still alive, or `nil` if it has been destroyed.
     */
    func promote() -> AndroidBinder? {
        handle.promote()
    }

    /**
     * Clones this weak reference.
     *
     * Useful because even if a weak binder currently promotes to `nil`, after
     * further binder transactions it may become promotable again.
     *
     * Available since API level 31.
     *
     * \return a new independent weak reference to the same binder, or `nil` on allocation failure.
     */
    @available(Android 31, *)
    func clone() -> AndroidBinderWeak? {
        handle.clone().map { AndroidBinderWeak($0) }
    }

    /**
     * Whether this weak reference compares less than another, providing a stable
     * ordering for use in sorted collections.
     *
     * Available since API level 31.
     */
    @available(Android 31, *)
    func isLess(than other: borrowing AndroidBinderWeak) -> Bool {
        handle.isLess(than: other.handle)
    }
}

// MARK: - Supporting Types

internal extension AndroidBinderWeak {

    struct Handle {

        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }
}

internal extension AndroidBinderWeak.Handle {

    static func create(from binder: AndroidBinder) -> AndroidBinderWeak.Handle? {
        AIBinder_Weak_new(binder.handle.pointer).map { .init($0) }
    }

    func delete() {
        AIBinder_Weak_delete(pointer)
    }

    func promote() -> AndroidBinder? {
        AIBinder_Weak_promote(pointer).map { AndroidBinder($0) }
    }

    @available(Android 31, *)
    func clone() -> AndroidBinderWeak.Handle? {
        AIBinder_Weak_clone(pointer).map { .init($0) }
    }

    @available(Android 31, *)
    func isLess(than other: AndroidBinderWeak.Handle) -> Bool {
        AIBinder_Weak_lt(pointer, other.pointer)
    }
}
