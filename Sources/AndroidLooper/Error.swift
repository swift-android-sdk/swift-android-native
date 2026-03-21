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

import AndroidSystem

/// Android Looper Error
public enum AndroidLooperError: Swift.Error {
    
    /// Underlying Bionic Error
    case bionic(Errno)
    
    case addFileDescriptor(FileDescriptor)
    
    /// Unable to remove the file descriptor.
    case removeFileDescriptor(FileDescriptor)
    
    /// File Descriptor not registered
    case fileDescriptorNotRegistered(FileDescriptor)
    
    /// Poll Timeout
    case pollTimeout
    
    /// Poll Error
    case pollError
}
