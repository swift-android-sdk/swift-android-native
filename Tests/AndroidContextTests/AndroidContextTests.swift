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
import SwiftJavaJNICore
#if os(Android)
import CAndroidNDK
#endif

#if !os(iOS)
struct AndroidContextTests {
    func testAndroidContext() throws {
        #if os(Android)
        let nativeActivity: ANativeActivity! = nil
        AndroidContext.contextPointer = nativeActivity.clazz
        #endif
        let context = try AndroidContext.application
        let assetManager: AssetManager = context.assetManager
        var directory = try assetManager.openDirectory("")
        while let item = directory.next() {
            print("asset item: \(item)")
        }
    }
}
#endif
