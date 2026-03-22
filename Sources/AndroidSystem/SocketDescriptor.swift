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

/// Native Socket handle.
///
/// Same as ``FileDescriptor`` on POSIX and opaque type on Windows.
public struct SocketDescriptor: RawRepresentable, Equatable, Hashable, Sendable {
    
    /// Native POSIX Socket handle
    public typealias RawValue = FileDescriptor.RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public let rawValue: RawValue
}

// MARK: - Operations

extension SocketDescriptor {
    
    /// Deletes a file descriptor.
    ///
    /// Deletes the file descriptor from the per-process object reference table.
    /// If this is the last reference to the underlying object,
    /// the object will be deactivated.
    ///
    /// The corresponding C function is `close`.
    @_alwaysEmitIntoClient
    public func close() throws(Errno) { try _close().get() }

    @usableFromInline
    internal func _close() -> Result<(), Errno> {
      nothingOrErrno(retryOnInterrupt: false) { system_close(self.rawValue) }
    }
    
    
    /// Reads bytes at the current file offset into a buffer.
    ///
    /// - Parameters:
    ///   - buffer: The region of memory to read into.
    ///   - retryOnInterrupt: Whether to retry the read operation
    ///     if it throws ``Errno/interrupted``.
    ///     The default is `true`.
    ///     Pass `false` to try only once and throw an error upon interruption.
    /// - Returns: The number of bytes that were read.
    ///
    /// The <doc://com.apple.documentation/documentation/swift/unsafemutablerawbufferpointer/3019191-count> property of `buffer`
    /// determines the maximum number of bytes that are read into that buffer.
    ///
    /// After reading,
    /// this method increments the file's offset by the number of bytes read.
    /// To change the file's offset,
    /// call the ``seek(offset:from:)`` method.
    ///
    /// The corresponding C function is `read`.
    @_alwaysEmitIntoClient
    public func read(
      into buffer: UnsafeMutableRawBufferPointer,
      retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
      try _read(into: buffer, retryOnInterrupt: retryOnInterrupt).get()
    }

    @usableFromInline
    internal func _read(
      into buffer: UnsafeMutableRawBufferPointer,
      retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
      valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
        system_read(self.rawValue, buffer.baseAddress, buffer.count)
      }
    }
    
    /// Writes the contents of a buffer at the current file offset.
    ///
    /// - Parameters:
    ///   - buffer: The region of memory that contains the data being written.
    ///   - retryOnInterrupt: Whether to retry the write operation
    ///     if it throws ``Errno/interrupted``.
    ///     The default is `true`.
    ///     Pass `false` to try only once and throw an error upon interruption.
    /// - Returns: The number of bytes that were written.
    ///
    /// After writing,
    /// this method increments the file's offset by the number of bytes written.
    /// To change the file's offset,
    /// call the ``seek(offset:from:)`` method.
    ///
    /// The corresponding C function is `write`.
    @_alwaysEmitIntoClient
    public func write(
      _ buffer: UnsafeRawBufferPointer,
      retryOnInterrupt: Bool = true
    ) throws(Errno) -> Int {
      try _write(buffer, retryOnInterrupt: retryOnInterrupt).get()
    }

    @usableFromInline
    internal func _write(
      _ buffer: UnsafeRawBufferPointer,
      retryOnInterrupt: Bool
    ) -> Result<Int, Errno> {
      valueOrErrno(retryOnInterrupt: retryOnInterrupt) {
        system_write(self.rawValue, buffer.baseAddress, buffer.count)
      }
    }
}
