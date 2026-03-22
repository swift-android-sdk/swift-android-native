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
public struct StorageManager: ~Copyable {

    internal let pointer: OpaquePointer

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    deinit {
        AStorageManager_delete(pointer)
    }
}

// MARK: - Initialization

public extension StorageManager {

    /// Creates an `AStorageManager` instance.
    init() throws(AndroidFileManagerError) {
        guard let pointer = AStorageManager_new() else {
            throw .invalidStorageManager
        }
        self.init(pointer: pointer)
    }
}

// MARK: - OBB Methods

public extension StorageManager {

    /// Asks Android to mount an OBB container.
    func mountObb(path: String, key: String? = nil) {
        path.withCString { pathCString in
            if let key {
                key.withCString { keyCString in
                    AStorageManager_mountObb(pointer, pathCString, keyCString, nil, nil)
                }
            } else {
                AStorageManager_mountObb(pointer, pathCString, nil, nil, nil)
            }
        }
    }

    /// Asks Android to mount an OBB container, invoking `onComplete` when done.
    ///
    /// The callback receives the OBB path and the resulting `ObbState`.
    func mountObb(path: String, key: String? = nil, onComplete: @escaping (String, ObbState) -> Void) {
        let box = Unmanaged.passRetained(ObbCallback(onComplete))
        let thunk: @convention(c) (UnsafePointer<CChar>?, Int32, UnsafeMutableRawPointer?) -> Void = { filename, state, data in
            let box = Unmanaged<ObbCallback>.fromOpaque(data!).takeRetainedValue()
            let path = filename.map { String(cString: $0) } ?? ""
            box.body(path, ObbState(rawValue: state) ?? .errorInternal)
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

    /// Asks Android to unmount an OBB container.
    func unmountObb(path: String, force: Bool = false) {
        path.withCString {
            AStorageManager_unmountObb(pointer, $0, force ? 1 : 0, nil, nil)
        }
    }

    /// Asks Android to unmount an OBB container, invoking `onComplete` when done.
    ///
    /// The callback receives the OBB path and the resulting `ObbState`.
    func unmountObb(path: String, force: Bool = false, onComplete: @escaping (String, ObbState) -> Void) {
        let box = Unmanaged.passRetained(ObbCallback(onComplete))
        let thunk: @convention(c) (UnsafePointer<CChar>?, Int32, UnsafeMutableRawPointer?) -> Void = { filename, state, data in
            let box = Unmanaged<ObbCallback>.fromOpaque(data!).takeRetainedValue()
            let path = filename.map { String(cString: $0) } ?? ""
            box.body(path, ObbState(rawValue: state) ?? .errorInternal)
        }
        path.withCString {
            AStorageManager_unmountObb(pointer, $0, force ? 1 : 0, thunk, box.toOpaque())
        }
    }

    /// Returns whether the OBB at `path` is mounted.
    func isObbMounted(path: String) -> Bool {
        path.withCString { rawPath in
            AStorageManager_isObbMounted(pointer, rawPath) != 0
        }
    }

    /// Returns the mounted OBB path for a raw OBB path.
    func mountedObbPath(for path: String) -> String? {
        path.withCString { rawPath in
            guard let cString = AStorageManager_getMountedObbPath(pointer, rawPath) else {
                return nil
            }
            return String(cString: cString)
        }
    }
}

// MARK: - Supporting Types

/// Box for bridging a Swift OBB callback to a C function pointer.
private final class ObbCallback {
    let body: (String, ObbState) -> Void
    init(_ body: @escaping (String, ObbState) -> Void) {
        self.body = body
    }
}
