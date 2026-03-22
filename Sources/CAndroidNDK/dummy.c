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

#ifdef __ANDROID__

#include <jni.h>
#include <android/log.h>
#include <android/configuration.h>
#include <dlfcn.h>

// Weak stubs for NDK functions introduced after the minimum supported API level.
// These are overridden by the real implementations when running on a device that
// supports them; they exist solely to satisfy the linker for older API targets.

// AConfiguration_getScreenRound / AConfiguration_setScreenRound: introduced in API 30
__attribute__((weak)) int32_t AConfiguration_getScreenRound(AConfiguration* config) {
    (void)config;
    return 0; // ACONFIGURATION_SCREENROUND_ANY
}

__attribute__((weak)) void AConfiguration_setScreenRound(AConfiguration* config, int32_t value) {
    (void)config;
    (void)value;
}

#endif
