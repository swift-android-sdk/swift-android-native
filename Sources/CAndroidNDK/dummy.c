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

<<<<<<<< HEAD:Sources/AndroidLooper/Extensions/Duration.swift
@available(macOS 13.0, *)
internal extension Duration {
    
    var milliseconds: Double {
        Double(components.seconds) * 1000 + Double(components.attoseconds) * 1e-15
    }
}
========
#ifdef __ANDROID__

#include <jni.h>
#include <android/log.h>
#include <dlfcn.h>

#endif
>>>>>>>> main:Sources/CAndroidNDK/dummy.c
