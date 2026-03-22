//
//  BinderClass.swift
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
 * Represents a type of AIBinder object which can be sent across processes.
 *
 * This object has no lifecycle. It is intended to be created as a static object and reused. It
 * is not able to be created on the stack.
 *
 * Available since API level 29.
 */
public struct BinderClass {
    
    internal let pointer: OpaquePointer

    internal init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }

    // AIBinder_Class has static lifetime — no deinit
}

// MARK: - Initialization

public extension BinderClass {

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
     *   AIBinder_new and returns a user-data pointer stored on the binder.
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
        guard let pointer = descriptor.withCString({ cString in
            AIBinder_Class_define(cString, onCreate, onDestroy, onTransact)
        }) else {
            return nil
        }
        self.init(pointer)
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
        guard let cStr = AIBinder_Class_getDescriptor(pointer) else {
            return ""
        }
        return String(cString: cStr)
    }
}

// MARK: - Methods

public extension BinderClass {

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
        AIBinder_Class_setOnDump(pointer, handler)
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
        AIBinder_Class_setHandleShellCommand(pointer, handler)
    }

    /**
     * Disables the interface token header for this class.
     *
     * When disabled, the interface token is not written to or verified from the parcel
     * header. This is intended for classes that do not use AIDL-generated code.
     *
     * Available since API level 35.
     */
    @available(Android 35, *)
    func disableInterfaceTokenHeader() {
        AIBinder_Class_disableInterfaceTokenHeader(pointer)
    }
}
