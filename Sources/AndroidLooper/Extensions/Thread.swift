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

#if canImport(Foundation)
import Foundation

public extension Thread {

    /**
     * Prepares a looper associated with the calling thread, and returns it.
     * If the thread already has a looper, it is returned.  Otherwise, a new
     * one is created, associated with the thread, and returned.
     *
     * The opts may be `ALOOPER_PREPARE_ALLOW_NON_CALLBACKS` or 0.
     */
    @_alwaysEmitIntoClient
    static func withLooper<T, E>(
        options: Looper.PrepareOptions = [],
        _ body: (borrowing Looper) throws(E) -> T
    ) throws(E) -> T {
        try Looper.currentThread(options: options, body)
    }
}
#endif
