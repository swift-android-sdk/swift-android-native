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

import SwiftJavaJNICore

public enum AndroidContextError: Error {

    case classNotFound(String)
    case methodNotFound(String)
    case nullValueForMethod(String)
    case invalidSignature(String)
    case virtualMachine(Error)
    // TODO: needs https://github.com/swiftlang/swift-java-jni-core/pull/12
    //case virtualMachine(JavaVirtualMachine.VMError)
}
