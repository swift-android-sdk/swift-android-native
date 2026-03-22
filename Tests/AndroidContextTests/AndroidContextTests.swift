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
import AndroidAssetManager
import OSLog
import SwiftJavaJNICore

struct AndroidContextTests {
    @Test func testAndroidContext() throws {
        let logger = Logger(subsystem: "AndroidContextTests", category: "testAndroidContext")
        #if os(Android)

        let context = try AndroidContext.application
        logger.info("context package name: \(try context.getPackageName() ?? "")")
        #expect(try context.getPackageName() == "org.swift.test.swift_android_native") // the default package name in `skip android test --apk`
        let assetManager: AssetManager = context.assetManager
        var directory = try assetManager.openDirectory("")
        while let item = directory.next() {
            print("asset item: \(item)")
        }
        #endif
    }
}
