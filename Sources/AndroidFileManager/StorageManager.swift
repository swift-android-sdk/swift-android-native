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

/// Wrapper around Android `AStorageManager`.
public struct StorageManager: ~Copyable, @unchecked Sendable {

    internal let handle: Handle

    internal init(_ handle: Handle) {
        self.handle = handle
    }

    deinit {
        handle.delete()
    }
}

// MARK: - Initialization

public extension StorageManager {

    /// Creates an `AStorageManager` instance.
    init() {
        guard let handle = Handle.create() else {
            fatalError("AStorageManager_new() failed")
        }
        self.init(handle)
    }
}

// MARK: - OBB Methods

public extension StorageManager {

    /// Asks Android to mount an OBB container, returning the resulting `ObbState`.
    func mountObb(path: String, key: String? = nil) async throws(AndroidFileManagerError) -> ObbState {
        try await withCheckedContinuation { continuation in
            handle.mountObb(path: path, key: key) { _, state in
                continuation.resume(returning: state)
            }
        }.get()
    }

    /// Asks Android to unmount an OBB container, returning the resulting `ObbState`.
    func unmountObb(path: String, force: Bool = false) async throws(AndroidFileManagerError) -> ObbState {
        try await withCheckedContinuation { continuation in
            handle.unmountObb(path: path, force: force) { _, state in
                continuation.resume(returning: state)
            }
        }.get()
    }

    /// Returns whether the OBB at `path` is mounted.
    func isObbMounted(path: String) -> Bool {
        handle.isObbMounted(path: path)
    }

    /// Returns the mounted OBB path for a raw OBB path.
    func mountedObbPath(for path: String) -> String? {
        handle.mountedObbPath(for: path)
    }
}

// MARK: - Supporting Types

internal extension StorageManager {

    struct Handle {

        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }
}

internal extension StorageManager.Handle {

    static func create() -> StorageManager.Handle? {
        AStorageManager_new().map { .init($0) }
    }

    func delete() {
        AStorageManager_delete(pointer)
    }

    func mountObb(path: String, key: String? = nil, onComplete: @escaping (String, ObbStateResult) -> Void) {
        let box = Unmanaged.passRetained(ObbCallback(onComplete))
        let thunk: @convention(c) (UnsafePointer<CChar>?, Int32, UnsafeMutableRawPointer?) -> Void = { filename, state, data in
            let box = Unmanaged<ObbCallback>.fromOpaque(data!).takeRetainedValue()
            let path = filename.map { String(cString: $0) } ?? ""
            box.body(path, ObbStateResult(state))
        }
        path.withCString { pathCString in
            if let key {
                key.withCString { keyCString in
                    AStorageManager_mountObb(pointer, pathCString, keyCString, thunk, box.toOpaque())
                }
            } else {
                AStorageManager_mountObb(pointer, pathCString, nil, thunk, box.toOpaque())
            }
        }
    }

    func unmountObb(path: String, force: Bool = false, onComplete: @escaping (String, ObbStateResult) -> Void) {
        let box = Unmanaged.passRetained(ObbCallback(onComplete))
        let thunk: @convention(c) (UnsafePointer<CChar>?, Int32, UnsafeMutableRawPointer?) -> Void = { filename, state, data in
            let box = Unmanaged<ObbCallback>.fromOpaque(data!).takeRetainedValue()
            let path = filename.map { String(cString: $0) } ?? ""
            box.body(path, ObbStateResult(state))
        }
        path.withCString {
            AStorageManager_unmountObb(pointer, $0, force ? 1 : 0, thunk, box.toOpaque())
        }
    }

    func isObbMounted(path: String) -> Bool {
        path.withCString { rawPath in
            AStorageManager_isObbMounted(pointer, rawPath) != 0
        }
    }

    func mountedObbPath(for path: String) -> String? {
        path.withCString { rawPath in
            guard let cString = AStorageManager_getMountedObbPath(pointer, rawPath) else {
                return nil
            }
            return String(cString: cString)
        }
    }
}

// MARK: - ObbCallback

/// Box for bridging a Swift OBB callback to a C function pointer.
internal final class ObbCallback {
    let body: (String, ObbStateResult) -> Void
    init(_ body: @escaping (String, ObbStateResult) -> Void) {
        self.body = body
    }
}
