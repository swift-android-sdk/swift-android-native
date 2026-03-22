//
//  AndroidBinderWeak.swift
//  SwiftAndroid
//
//  Created by Alsey Coleman Miller on 7/6/25.
//

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

    /**
     * Available since API level 29.
     */
    static func create(from binder: AndroidBinder) -> AndroidBinderWeak.Handle? {
        binder.withUnsafePointer { AIBinder_Weak_new($0) }.map { .init($0) }
    }

    /**
     * Available since API level 29.
     */
    func delete() {
        AIBinder_Weak_delete(pointer)
    }

    /**
     * Available since API level 29.
     */
    func promote() -> AndroidBinder? {
        AIBinder_Weak_promote(pointer).map { AndroidBinder($0) }
    }

    /**
     * Available since API level 31.
     */
    @available(Android 31, *)
    func isLess(than other: AndroidBinderWeak.Handle) -> Bool {
        AIBinder_Weak_lt(pointer, other.pointer)
    }
}
