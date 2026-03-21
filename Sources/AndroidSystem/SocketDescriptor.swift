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
