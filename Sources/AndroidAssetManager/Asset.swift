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
import AndroidSystem

/// A handle to an `AAsset`.
///
/// Asset values own their pointer and close it during deinitialization.
public struct Asset: ~Copyable {

    internal let pointer: OpaquePointer

    internal init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }

    deinit {
        AAsset_close(pointer)
    }
}

// MARK: - Properties

public extension Asset {

    /// Total uncompressed length of this asset in bytes.
    var length: Int64 {
        AAsset_getLength64(pointer)
    }

    /// Remaining unread bytes in this asset.
    var remainingLength: Int64 {
        AAsset_getRemainingLength64(pointer)
    }

    /// Whether the asset is backed by a memory allocation.
    var isAllocated: Bool {
        AAsset_isAllocated(pointer) != 0
    }
}

// MARK: - Methods

public extension Asset {

    enum SeekOrigin: Int32, Sendable {
        case start = 0
        case current = 1
        case end = 2
    }

    /// Reads up to `maxCount` bytes from the current cursor position.
    func read(maxCount: Int = 4096) throws(AndroidFileManagerError) -> [UInt8] {
        guard maxCount > 0 else { return [] }
        var bytes = [UInt8](repeating: 0, count: maxCount)
        let count = bytes.withUnsafeMutableBytes {
            AAsset_read(pointer, $0.baseAddress, maxCount)
        }
        guard count >= 0 else { throw .readAsset(count) }
        bytes.removeSubrange(Int(count)...)
        return bytes
    }

    /// Reads and returns all remaining bytes.
    func readAll(chunkSize: Int = 4096) throws(AndroidFileManagerError) -> [UInt8] {
        guard chunkSize > 0 else { return [] }
        // Fast path: asset is backed by a contiguous buffer — single copy.
        if let bytes = withUnsafeBufferPointer({ Array($0) }) {
            return bytes
        }
        // Slow path: chunked reads.
        var output = [UInt8]()
        output.reserveCapacity(Int(max(remainingLength, 0)))
        while true {
            let chunk = try read(maxCount: chunkSize)
            if chunk.isEmpty { break }
            output.append(contentsOf: chunk)
        }
        return output
    }

    /// Seeks the asset cursor and returns the new absolute position.
    ///
    /// - Parameters:
    ///   - offset: Signed offset.
    ///   - whence: `SEEK_SET`, `SEEK_CUR`, or `SEEK_END`.
    func seek(offset: Int64, whence: SeekOrigin = .start) throws(AndroidFileManagerError) -> Int64 {
        let result = AAsset_seek64(pointer, offset, whence.rawValue)
        guard result >= 0 else {
            throw .seekAsset(result)
        }
        return result
    }

    /// Returns a file descriptor and byte range when available.
    func open() -> (fileDescriptor: FileDescriptor, start: Int64, length: Int64)? {
        var start: Int64 = 0
        var length: Int64 = 0
        let fd = AAsset_openFileDescriptor64(pointer, &start, &length)
        guard fd >= 0 else {
            return nil
        }
        return (FileDescriptor(rawValue: fd), start, length)
    }

    /// Returns an in-memory buffer, if this asset exposes one.
    func withUnsafeBufferPointer<T>(
        _ body: (UnsafeRawBufferPointer) throws -> T
    ) rethrows -> T? {
        guard let baseAddress = AAsset_getBuffer(pointer) else {
            return nil
        }
        let count = Int(max(length, 0))
        let buffer = UnsafeRawBufferPointer(start: baseAddress, count: count)
        return try body(buffer)
    }

    /// Calls `body` with a zero-copy ``RawSpan`` over the asset's in-memory buffer.
    ///
    /// Unlike ``withUnsafeBufferPointer(_:)``, the span carries compile-time lifetime
    /// tracking that prevents it from escaping the closure.
    ///
    /// - Returns: `nil` if the asset is not backed by a contiguous memory region.
    func withRawSpan<E: Error, T>(
        _ body: (RawSpan) throws(E) -> T
    ) throws(E) -> T? {
        guard let baseAddress = AAsset_getBuffer(pointer) else { return nil }
        let count = Int(max(length, 0))
        let rawBuffer = UnsafeRawBufferPointer(start: baseAddress, count: count)
        return try body(rawBuffer.bytes)
    }
}
