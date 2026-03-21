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
/// __android_log_write(int prio, const char *tag, const char *text)
internal func __android_log_write(_ priority: CInt, _ tag: UnsafePointer<CChar>?, _ text: UnsafePointer<CChar>?) -> CInt {
    fatalError("shim")
}
#endif
