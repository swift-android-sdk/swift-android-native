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

#if os(Linux) || os(Android)
public extension SocketDescriptor {
    
    /// File descriptor for event notification
    ///
    /// An "eventfd object" can be used as an event wait/notify mechanism by user-space applications, and by the kernel to notify user-space applications of events.
    /// The object contains an unsigned 64-bit integer counter that is maintained by the kernel.
    struct Event: RawRepresentable, Equatable, Hashable, Sendable {
        
        public typealias RawValue = FileDescriptor.RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
}

// MARK: - Supporting Types

public extension SocketDescriptor.Event {
    
    /// Flags when opening sockets.
    @frozen
    struct Flags: OptionSet, Hashable, Codable, Sendable {
        
        /// The raw C file events.
        @_alwaysEmitIntoClient
        public let rawValue: CInt

        /// Create a strongly-typed file events from a raw C value.
        @_alwaysEmitIntoClient
        public init(rawValue: CInt) { self.rawValue = rawValue }

        @_alwaysEmitIntoClient
        private init(_ raw: CInt) {
            self.init(rawValue: raw)
        }
    }
}

public extension SocketDescriptor.Event.Flags {
    
    /// Set the close-on-exec (`FD_CLOEXEC`) flag on the new file descriptor.
    ///
    /// See the description of the `O_CLOEXEC` flag in `open(2)` for reasons why this may be useful.
    @_alwaysEmitIntoClient
    static var nonBlocking: SocketDescriptor.Event.Flags { SocketDescriptor.Event.Flags(_EFD_NONBLOCK) }

    /// Set the `O_NONBLOCK` file status flag on the new open file description.
    ///
    /// Using this flag saves extra calls to `fcntl(2)` to achieve the same result.
    @_alwaysEmitIntoClient
    static var closeOnExec: SocketDescriptor.Event.Flags { SocketDescriptor.Event.Flags(_EFD_CLOEXEC) }
    
    /// Provide semaphore-like semantics for reads from the new file descriptor.
    @_alwaysEmitIntoClient
    static var semaphore: SocketDescriptor.Event.Flags { SocketDescriptor.Event.Flags(_EFD_SEMAPHORE) }
}

// @available(macOS 10.16, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension SocketDescriptor.Event.Flags: CustomStringConvertible, CustomDebugStringConvertible
{
    /// A textual representation of the open options.
    @inline(never)
    public var description: String {
        let descriptions: [(Element, StaticString)] = [
            (.nonBlocking, ".nonBlocking"),
            (.closeOnExec, ".closeOnExec"),
            (.semaphore, ".semaphore"),
        ]
        return _buildDescription(descriptions)
    }
    
    /// A textual representation of the open options, suitable for debugging.
    public var debugDescription: String { self.description }
}

public extension SocketDescriptor.Event {
    
    @frozen
    struct Counter: RawRepresentable, Equatable, Hashable, Sendable {
        
        public typealias RawValue = UInt64
        
        @_alwaysEmitIntoClient
        public var rawValue: RawValue
        
        @_alwaysEmitIntoClient
        public init(rawValue: RawValue = 0) {
            self.rawValue = rawValue
        }
    }
}

extension SocketDescriptor.Event.Counter: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
}

extension SocketDescriptor.Event.Counter: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String { rawValue.description }
    
    public var debugDescription: String { description }
}
#endif
