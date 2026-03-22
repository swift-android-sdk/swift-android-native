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
 * Represents a type of AIBinder object which can be sent across processes.
 *
 * This object has no lifecycle. It is intended to be created as a static object and reused. It
 * is not able to be created on the stack.
 *
 * Available since API level 29.
 */
@available(Android 29, *)
public struct BinderClass {

    internal let handle: Handle

    internal init(_ handle: Handle) {
        self.handle = handle
    }

    // AIBinder_Class has static lifetime — no deinit
}

// MARK: - Initialization

public extension BinderClass {

    /// Directly initialize from a pointer.
    init(_ pointer: OpaquePointer) {
        self.handle = .init(pointer)
    }

    /**
     * Creates a new binder class.
     *
     * This is to be called once, e.g. as a static variable, to define a class and associate
     * callbacks with it. The class pointer is never freed.
     *
     * Available since API level 29.
     *
     * \param descriptor a unique identifier for the class, used for sanity checks on transactions.
     * \param onCreate called when a new local binder is instantiated; receives the args passed to
     *   `AIBinder_new` and returns a user-data pointer stored on the binder.
     * \param onDestroy called when the last strong reference to a local binder is dropped.
     * \param onTransact called to dispatch incoming transactions.
     *
     * \return a new binder class, or nil on error.
     */
    init?(
        descriptor: String,
        onCreate: (@convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?)?,
        onDestroy: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?,
        onTransact: (@convention(c) (OpaquePointer?, UInt32, OpaquePointer?, OpaquePointer?) -> binder_status_t)?
    ) {
        guard
            let handle = Handle.define(
                descriptor: descriptor,
                onCreate: onCreate,
                onDestroy: onDestroy,
                onTransact: onTransact
            )
        else {
            return nil
        }
        self.init(handle)
    }
}

// MARK: - Properties

public extension BinderClass {

    /**
     * Returns the interface descriptor associated with this class.
     *
     * Available since API level 31.
     */
    @available(Android 31, *)
    var descriptor: String {
        handle.descriptor
    }
}

// MARK: - Methods

public extension BinderClass {

    /// Access the underlying opaque pointer.
    func withUnsafePointer<E, Result>(_ body: (OpaquePointer) throws(E) -> Result) throws(E) -> Result where E: Error {
        try body(handle.pointer)
    }

    /**
     * Sets the implementation of the dump method for this class.
     *
     * Must be called before any instance of this class is created.
     *
     * Available since API level 29.
     */
    func setOnDump(
        _ handler: (@convention(c) (OpaquePointer?, Int32, UnsafePointer<UnsafePointer<CChar>?>?, UInt32) -> binder_status_t)?
    ) {
        handle.setOnDump(handler)
    }

    /**
     * Sets the implementation of the shell command handler for this class.
     *
     * Available since API level 31.
     */
    @available(Android 31, *)
    func setHandleShellCommand(
        _ handler: (@convention(c) (OpaquePointer?, Int32, Int32, Int32, UnsafePointer<UnsafePointer<CChar>?>?, UInt32) -> binder_status_t)?
    ) {
        handle.setHandleShellCommand(handler)
    }

    /**
     * Disables the interface token header for this class.
     *
     * When disabled, the interface token is not written to or verified from the parcel
     * header. This is intended for classes that do not use AIDL-generated code.
     *
     * Available since API level 33.
     */
    @available(Android 33, *)
    func disableInterfaceTokenHeader() {
        handle.disableInterfaceTokenHeader()
    }

    #if ANDROID_NDK_VERSION_30
    /**
     * Returns the function name associated with the given transaction code for this class.
     *
     * Useful for debugging and tracing binder transactions.
     *
     * Available since API level 35.
     *
     * \param code the transaction code to look up.
     * \return the function name, or `nil` if no name is associated with the code.
     */
    @available(Android 35, *)
    func transactionName(for code: UInt32) -> String? {
        handle.transactionName(for: code)
    }

    /**
     * Associates a mapping of transaction codes to function names for this class.
     *
     * Used to provide human-readable names for transactions in debugging and tracing.
     *
     * Available since API level 35.
     *
     * \param map an array of function names, indexed by transaction code.
     */
    @available(Android 35, *)
    func setTransactionCodeToFunctionName(_ map: [String?]) {
        handle.setTransactionCodeToFunctionName(map)
    }
    #endif
}

// MARK: - Supporting Types

internal extension BinderClass {

    struct Handle {

        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }
}

internal extension BinderClass.Handle {

    static func define(
        descriptor: String,
        onCreate: (@convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?)?,
        onDestroy: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?,
        onTransact: (@convention(c) (OpaquePointer?, UInt32, OpaquePointer?, OpaquePointer?) -> binder_status_t)?
    ) -> BinderClass.Handle? {
        descriptor.withCString { cString in
            AIBinder_Class_define(cString, onCreate, onDestroy, onTransact)
        }.map { .init($0) }
    }

    @available(Android 31, *)
    var descriptor: String {
        guard let cStr = AIBinder_Class_getDescriptor(pointer) else {
            return ""
        }
        return String(cString: cStr)
    }

    func setOnDump(
        _ handler: (@convention(c) (OpaquePointer?, Int32, UnsafePointer<UnsafePointer<CChar>?>?, UInt32) -> binder_status_t)?
    ) {
        AIBinder_Class_setOnDump(pointer, handler)
    }

    @available(Android 31, *)
    func setHandleShellCommand(
        _ handler: (@convention(c) (OpaquePointer?, Int32, Int32, Int32, UnsafePointer<UnsafePointer<CChar>?>?, UInt32) -> binder_status_t)?
    ) {
        AIBinder_Class_setHandleShellCommand(pointer, handler)
    }

    @available(Android 33, *)
    func disableInterfaceTokenHeader() {
        AIBinder_Class_disableInterfaceTokenHeader(pointer)
    }

    #if ANDROID_NDK_VERSION_30
    @available(Android 35, *)
    func transactionName(for code: UInt32) -> String? {
        AIBinder_Class_getTransactionName(pointer, code).map { String(cString: $0) }
    }

    @available(Android 35, *)
    func setTransactionCodeToFunctionName(_ map: [String?]) {
        var cStrings = map.map { $0.map { strdup($0) } }
        defer { cStrings.forEach { $0.map { free($0) } } }
        var ptrs = cStrings.map { $0.map { UnsafePointer($0) } }
        ptrs.withUnsafeBufferPointer { buffer in
            AIBinder_Class_associateTransactionCodeToFunctionName(pointer, buffer.baseAddress, map.count)
        }
    }
    #endif
}
