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

@_exported import SwiftJavaJNICore
@_exported import AndroidFileManager
@_exported import AndroidLogging
@_exported import AndroidLooper
@_exported import AndroidChoreographer

#if canImport(Android)
import Android
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Utilities for setting up Android compatibility with Foundation
public class AndroidBootstrap {
}
#endif
