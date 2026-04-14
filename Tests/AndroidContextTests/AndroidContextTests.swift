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

import Testing
import AndroidContext
import AndroidFileManager
#if canImport(OSLog)
import OSLog // note: on non-android platforms, this will just export the system OSLog
#else
import AndroidLogging
#endif
import SwiftJavaJNICore

#if os(Android)
let android = true
#else
let android = false
#endif

@Suite(.enabled(if: android))
struct AndroidContextTests {
    @Test func testAndroidContext() throws {
        let logger = Logger(subsystem: "AndroidContextTests", category: "testAndroidContext")
        let context = try AndroidContext.application
        let packageName = try context.getPackageName()
        logger.info("context package name: \(packageName ?? "")")
        #expect(try context.getPackageName() == "org.swift.test.swift_android_native") // the default package name in `skip android test --apk`
        let assetManager: AssetManager = context.assetManager
        var directory = try assetManager.openDirectory("")
        while let item = directory.next() {
            print("asset item: \(item)")
        }
    }
}
