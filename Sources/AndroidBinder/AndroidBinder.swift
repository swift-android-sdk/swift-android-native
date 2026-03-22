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
import AndroidSystem

/**
 * Represents a local or remote object which can be used for IPC or which can itself be sent.
 *
 * This object has a refcount associated with it and will be deleted when its refcount reaches zero.
 * How methods interactive with this refcount is described below. When using this API, it is
 * intended for a client of a service to hold a strong reference to that service. This also means
 * that user data typically should hold a strong reference to a local AIBinder object. A remote
 * AIBinder object automatically holds a strong reference to the AIBinder object in the server's
 * process. A typically memory layout looks like this:
 *
 * Key:
 *   --->         Ownership/a strong reference
 *   ...>         A weak reference
 *
 *                         (process boundary)
 *                                 |
 * MyInterface ---> AIBinder_Weak  |  ProxyForMyInterface
 *      ^                .         |          |
 *      |                .         |          |
 *      |                v         |          v
 *   UserData  <---   AIBinder   <-|-      AIBinder
 *                                 |
 *
 * In this way, you'll notice that a proxy for the interface holds a strong reference to the
 * implementation and that in the server process, the AIBinder object which was sent can be resent
 * so that the same AIBinder object always represents the same object. This allows, for instance, an
 * implementation (usually a callback) to transfer all ownership to a remote process and
 * automatically be deleted when the remote process is done with it or dies. Other memory models are
 * possible, but this is the standard one.
 *
 * If the process containing an AIBinder dies, it is possible to be holding a strong reference to
 * an object which does not exist. In this case, transactions to this binder will return
 * STATUS_DEAD_OBJECT. See also AIBinder_linkToDeath, AIBinder_unlinkToDeath, and AIBinder_isAlive.
 *
 * Once an AIBinder is created, anywhere it is passed (remotely or locally), there is a 1-1
 * correspondence between the address of an AIBinder and the object it represents. This means that
 * when two AIBinder pointers point to the same address, they represent the same object (whether
 * that object is local or remote). This correspondance can be broken accidentally if AIBinder_new
 * is erronesouly called to create the same object multiple times.
 */
@available(Android 29, *)
public final class AndroidBinder {

    internal let handle: Handle

    // MARK: - Initialization

    deinit {
        handle.release()
    }

    internal init(_ handle: Handle) {
        self.handle = handle
    }

    /// Directly initialize from a pointer.
    public init(_ pointer: OpaquePointer) {
        self.handle = .init(pointer)
    }

    /**
     * Creates a new local binder object of the given class.
     *
     * The `userData` pointer is passed to the class's `onCreate` callback and can be
     * retrieved later from within binder callbacks.
     *
     * The refcount starts at 1; the object is destroyed when it reaches zero.
     *
     * Available since API level 29.
     *
     * \param binderClass the type of the object to be created.
     * \param userData an arbitrary pointer forwarded to the class's `onCreate` callback.
     *
     * \return a binder object, or `nil` on failure.
     */
    public init?(class binderClass: BinderClass, userData: UnsafeMutableRawPointer? = nil) {
        guard let handle = Handle.create(class: binderClass, userData: userData) else {
            return nil
        }
        self.handle = handle
    }
}

// MARK: - Properties

public extension AndroidBinder {

    /**
     * Determine whether the current thread is currently executing an incoming transaction.
     *
     * Available since API level 33.
     *
     * \return true if the current thread is currently executing an incoming transaction, and false
     * otherwise.
     */
    @available(Android 33, *)
    static var isHandlingTransaction: Bool {
        AIBinder_isHandlingTransaction()
    }

    /**
     * This returns the calling UID assuming that this thread is called from a thread that is processing
     * a binder transaction (for instance, in the implementation of AIBinder_Class_onTransact).
     *
     * This can be used with higher-level system services to determine the caller's identity and check
     * permissions.
     *
     * Available since API level 29.
     *
     * \return calling uid or the current process's UID if this thread isn't processing a transaction.
     */
    static var callingUID: uid_t {
        AIBinder_getCallingUid()
    }

    /**
     * This returns the calling PID assuming that this thread is called from a thread that is processing
     * a binder transaction (for instance, in the implementation of AIBinder_Class_onTransact).
     *
     * This can be used with higher-level system services to determine the caller's identity and check
     * permissions. However, when doing this, one should be aware of possible TOCTOU problems when the
     * calling process dies and is replaced with another process with elevated permissions and the same
     * PID.
     *
     * Warning: oneway transactions do not receive PID. Even if you expect
     * a transaction to be synchronous, a misbehaving client could send it
     * as a synchronous call and result in a 0 PID here. Additionally, if
     * there is a race and the calling process dies, the PID may still be
     * 0 for a synchronous call.
     *
     * Available since API level 29.
     *
     * \return calling pid or the current process's PID if this thread isn't processing a transaction.
     * If the transaction being processed is a oneway transaction, then this method will return 0.
     */
    static var callingPID: pid_t {
        AIBinder_getCallingPid()
    }

    /**
     * If this is hosted in a process other than the current one.
     *
     * Available since API level 29.
     *
     * \param binder the binder being queried.
     *
     * \return true if the AIBinder represents an object in another process.
     */
    var isRemote: Bool {
        handle.isRemote
    }

    /**
     * If this binder is known to be alive. This will not send a transaction to a remote process and
     * returns a result based on the last known information. That is, whenever a transaction is made,
     * this is automatically updated to reflect the current alive status of this binder. This will be
     * updated as the result of a transaction made using AIBinder_transact, but it will also be updated
     * based on the results of bookkeeping or other transactions made internally.
     *
     * Available since API level 29.
     *
     * \param binder the binder being queried.
     *
     * \return true if the binder is alive.
     */
    var isAlive: Bool {
        handle.isAlive
    }

    /**
     * The class this binder was constructed with or associated with.
     *
     * Available since API level 29.
     *
     * \return the class associated with this binder, or `nil` if none has been associated.
     */
    @available(Android 29, *)
    var binderClass: BinderClass? {
        handle.binderClass
    }

    /**
     * User data returned from `onCreate` when this local binder was created.
     * Always `nil` for remote binders.
     *
     * Available since API level 29.
     */
    @available(Android 29, *)
    var userData: UnsafeMutableRawPointer? {
        handle.userData
    }
}

// MARK: - Methods

public extension AndroidBinder {

    /// Access the underlying opaque pointer.
    func withUnsafePointer<E, Result>(_ body: (OpaquePointer) throws(E) -> Result) throws(E) -> Result where E: Error {
        try body(handle.pointer)
    }

    /**
     * Built-in transaction for all binder objects. This sends a transaction that will immediately
     * return. Usually this is used to make sure that a binder is alive, as a placeholder call, or as a
     * consistency check.
     *
     * Available since API level 29.
     *
     * \param binder the binder being queried.
     *
     * \return STATUS_OK if the ping succeeds.
     */
    func ping() throws(AndroidBinderError) {
        try handle.ping().get()
    }

    /**
     * Built-in transaction for all binder objects. This dumps information about a given binder.
     *
     * See also AIBinder_Class_setOnDump, AIBinder_onDump.
     *
     * Available since API level 29.
     *
     * \param binder the binder to dump information about
     * \param fd where information should be dumped to
     * \param args null-terminated arguments to pass (may be null if numArgs is 0)
     * \param numArgs number of args to send
     *
     * \return STATUS_OK if dump succeeds (or if there is nothing to dump)
     */
    func dump(to destination: FileDescriptor, arguments: [String] = []) throws(AndroidBinderError) {
        try handle.dump(to: destination, arguments: arguments).get()
    }

    /**
     * Associates this binder object with the given class.
     *
     * This is useful for a binder received from a remote process to verify
     * that it implements the expected interface before using it.
     *
     * Available since API level 29.
     *
     * \param binderClass the class to associate with this binder.
     *
     * \return true if the binder has the class and the association was successful.
     */
    @available(Android 29, *)
    @discardableResult
    func associate(class binderClass: BinderClass) -> Bool {
        handle.associate(class: binderClass)
    }

    /**
     * Gets the extension registered on this binder.
     *
     * See also `setExtension(_:)`.
     *
     * Available since API level 30.
     *
     * \return the extension binder, or `nil` if none is registered or on error.
     */
    @available(Android 30, *)
    func getExtension() throws(AndroidBinderError) -> AndroidBinder? {
        try handle.getExtension().get()
    }

    /**
     * Sets an extension on this binder. Must be called before the binder is passed to
     * another thread. Only valid on local binders.
     *
     * See also `getExtension()`.
     *
     * Available since API level 30.
     *
     * \param extension the binder to attach as an extension.
     */
    @available(Android 30, *)
    func setExtension(_ extension: AndroidBinder) throws(AndroidBinderError) {
        try handle.setExtension(`extension`).get()
    }

    /**
     * Whether this binder compares less than another, providing a stable ordering
     * for use in sorted collections.
     *
     * Two binders refer to the same object when neither `a.isLess(than: b)`
     * nor `b.isLess(than: a)` is true.
     *
     * Available since API level 31.
     */
    @available(Android 31, *)
    func isLess(than other: AndroidBinder) -> Bool {
        handle.isLess(than: other.handle)
    }

    /**
     * Creates a weak reference to this binder.
     *
     * Available since API level 29.
     *
     * \return a weak reference, or `nil` on allocation failure.
     */
    func weakReference() -> AndroidBinderWeak? {
        handle.weakReference()
    }

    /**
     * Registers a death recipient to be called when the remote process hosting this
     * binder dies.
     *
     * The `cookie` is passed back to the recipient's `onDied` callback.
     *
     * Available since API level 29.
     *
     * \param recipient the death recipient to register.
     * \param cookie an arbitrary pointer forwarded to the recipient's callbacks.
     */
    func linkToDeath(_ recipient: DeathRecipient, cookie: UnsafeMutableRawPointer? = nil) throws(AndroidBinderError) {
        try handle.linkToDeath(recipient, cookie: cookie).get()
    }

    /**
     * Unregisters a previously registered death recipient.
     *
     * Available since API level 29.
     *
     * \param recipient the death recipient to unregister.
     * \param cookie the cookie that was passed to `linkToDeath`.
     */
    func unlinkToDeath(_ recipient: DeathRecipient, cookie: UnsafeMutableRawPointer? = nil) throws(AndroidBinderError) {
        try handle.unlinkToDeath(recipient, cookie: cookie).get()
    }
}

// MARK: - Supporting Types

internal extension AndroidBinder {

    struct Handle {

        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }
}

internal extension AndroidBinder.Handle {

    /**
     * If this is hosted in a process other than the current one.
     *
     * Available since API level 29.
     *
     * \param binder the binder being queried.
     *
     * \return true if the AIBinder represents an object in another process.
     */
    var isRemote: Bool {
        AIBinder_isRemote(pointer)
    }

    /**
     * If this binder is known to be alive. This will not send a transaction to a remote process and
     * returns a result based on the last known information. That is, whenever a transaction is made,
     * this is automatically updated to reflect the current alive status of this binder. This will be
     * updated as the result of a transaction made using AIBinder_transact, but it will also be updated
     * based on the results of bookkeeping or other transactions made internally.
     *
     * Available since API level 29.
     *
     * \param binder the binder being queried.
     *
     * \return true if the binder is alive.
     */
    var isAlive: Bool {
        AIBinder_isAlive(pointer)
    }

    /**
     * For debugging only!
     *
     * Available since API level 29.
     *
     * \param binder the binder object to retrieve the refcount of.
     *
     * \return the number of strong-refs on this binder in this process. If binder is null, this will be
     * -1.
     */
    var debugReferenceCount: Int32 {
        AIBinder_debugGetRefCount(pointer)
    }

    /**
     * Built-in transaction for all binder objects. This sends a transaction that will immediately
     * return. Usually this is used to make sure that a binder is alive, as a placeholder call, or as a
     * consistency check.
     *
     * Available since API level 29.
     *
     * \param binder the binder being queried.
     *
     * \return STATUS_OK if the ping succeeds.
     */
    func ping() -> Result<Void, AndroidBinderError> {
        AIBinder_ping(pointer).mapError()
    }

    /**
     * This will delete the object and call onDestroy once the refcount reaches zero.
     *
     * Available since API level 29.
     *
     * \param binder the binder object to remove a refcount from.
     */
    func release() {
        AIBinder_decStrong(pointer)
    }

    /**
     * This can only be called if a strong reference to this object already exists in process.
     *
     * Available since API level 29.
     *
     * \param binder the binder object to add a refcount to.
     */
    func retain() {
        AIBinder_incStrong(pointer)
    }

    /**
     * Built-in transaction for all binder objects. This dumps information about a given binder.
     *
     * See also AIBinder_Class_setOnDump, AIBinder_onDump.
     *
     * Available since API level 29.
     *
     * \param binder the binder to dump information about
     * \param fd where information should be dumped to
     * \param args null-terminated arguments to pass (may be null if numArgs is 0)
     * \param numArgs number of args to send
     *
     * \return STATUS_OK if dump succeeds (or if there is nothing to dump)
     */
    func dump(to destination: FileDescriptor, arguments: [String] = []) -> Result<Void, AndroidBinderError> {
        var cStrings = arguments.map { strdup($0) }
        defer { cStrings.forEach { free($0) } }
        var ptrs = cStrings.map { UnsafePointer($0) }
        return ptrs.withUnsafeBufferPointer { buffer in
            AIBinder_dump(pointer, destination.rawValue, buffer.baseAddress, UInt32(arguments.count)).mapError()
        }
    }

    static func create(class binderClass: BinderClass, userData: UnsafeMutableRawPointer?) -> Handle? {
        AIBinder_new(binderClass.handle.pointer, userData).map { .init($0) }
    }

    var binderClass: BinderClass? {
        AIBinder_getClass(pointer).map { BinderClass($0) }
    }

    var userData: UnsafeMutableRawPointer? {
        AIBinder_getUserData(pointer)
    }

    func associate(class binderClass: BinderClass) -> Bool {
        AIBinder_associateClass(pointer, binderClass.handle.pointer)
    }

    @available(Android 30, *)
    func getExtension() -> Result<AndroidBinder?, AndroidBinderError> {
        var out: OpaquePointer?
        let status = AIBinder_getExtension(pointer, &out)
        return status.mapError(out.map { AndroidBinder($0) })
    }

    @available(Android 30, *)
    func setExtension(_ extension: AndroidBinder) -> Result<Void, AndroidBinderError> {
        AIBinder_setExtension(pointer, `extension`.handle.pointer).mapError()
    }

    @available(Android 31, *)
    func isLess(than other: Handle) -> Bool {
        AIBinder_lt(pointer, other.pointer)
    }

    func weakReference() -> AndroidBinderWeak? {
        AIBinder_Weak_new(pointer).map { AndroidBinderWeak($0) }
    }

    func linkToDeath(_ recipient: DeathRecipient, cookie: UnsafeMutableRawPointer?) -> Result<Void, AndroidBinderError> {
        AIBinder_linkToDeath(pointer, recipient.handle.pointer, cookie).mapError()
    }

    func unlinkToDeath(_ recipient: DeathRecipient, cookie: UnsafeMutableRawPointer?) -> Result<Void, AndroidBinderError> {
        AIBinder_unlinkToDeath(pointer, recipient.handle.pointer, cookie).mapError()
    }
}
