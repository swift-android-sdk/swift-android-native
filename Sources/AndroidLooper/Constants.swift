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

#if !os(Android)
import CoreFoundation

typealias AVsyncId = Int64

typealias AChoreographer_frameCallback = @convention(c) (Int, UnsafeMutableRawPointer?) -> Void
typealias AChoreographer_frameCallback64 = @convention(c) (Int64, UnsafeMutableRawPointer?) -> Void
typealias AChoreographer_vsyncCallback = @convention(c) (UnsafePointer<OpaquePointer>?, UnsafeMutableRawPointer?) -> Void
typealias AChoreographer_refreshRateCallback = @convention(c) (Int64, UnsafeMutableRawPointer?) -> Void

var ALOOPER_PREPARE_ALLOW_NON_CALLBACKS: Int { stub() }

var ALOOPER_EVENT_INPUT: Int { stub() }
var ALOOPER_EVENT_OUTPUT: Int { stub() }
var ALOOPER_EVENT_ERROR: Int { stub() }
var ALOOPER_EVENT_HANGUP: Int { stub() }
var ALOOPER_EVENT_INVALID: Int { stub() }

var ALOOPER_POLL_WAKE: Int { stub() }
var ALOOPER_POLL_CALLBACK: Int { stub() }
var ALOOPER_POLL_TIMEOUT: Int { stub() }
var ALOOPER_POLL_ERROR: Int { stub() }

#if canImport(Darwin)
// renamed on Darwin
var kCFRunLoopDefaultMode: CFRunLoopMode { .defaultMode }
#endif

#endif
