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

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import SwiftJavaJNICore

#if !os(Android)

func stub() -> Never {
    fatalError("Not running on Android")
}

// MARK: - AConfiguration

func AConfiguration_new() -> OpaquePointer? { stub() }

func AConfiguration_delete(_ config: OpaquePointer) { stub() }

func AConfiguration_fromAssetManager(_ out: OpaquePointer, _ am: OpaquePointer) { stub() }

func AConfiguration_copy(_ dest: OpaquePointer, _ src: OpaquePointer) { stub() }

func AConfiguration_diff(_ config1: OpaquePointer, _ config2: OpaquePointer) -> Int32 { stub() }

func AConfiguration_match(_ base: OpaquePointer, _ requested: OpaquePointer) -> Int32 { stub() }

func AConfiguration_isBetterThan(
    _ base: OpaquePointer,
    _ test: OpaquePointer,
    _ requested: OpaquePointer
) -> Int32 { stub() }

func AConfiguration_getMcc(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getMnc(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getLanguage(_ config: OpaquePointer, _ outLanguage: UnsafeMutablePointer<CChar>?) { stub() }

func AConfiguration_getCountry(_ config: OpaquePointer, _ outCountry: UnsafeMutablePointer<CChar>?) { stub() }

func AConfiguration_getOrientation(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getTouchscreen(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getDensity(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getKeyboard(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getNavigation(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getKeysHidden(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getNavHidden(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getSdkVersion(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getScreenSize(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getScreenLong(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getUiModeType(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getUiModeNight(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getScreenWidthDp(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getScreenHeightDp(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getSmallestScreenWidthDp(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getLayoutDirection(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getScreenRound(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_getGrammaticalGender(_ config: OpaquePointer) -> Int32 { stub() }

func AConfiguration_setMcc(_ config: OpaquePointer, _ mcc: Int32) { stub() }

func AConfiguration_setMnc(_ config: OpaquePointer, _ mnc: Int32) { stub() }

func AConfiguration_setLanguage(_ config: OpaquePointer, _ language: UnsafePointer<CChar>?) { stub() }

func AConfiguration_setCountry(_ config: OpaquePointer, _ country: UnsafePointer<CChar>?) { stub() }

func AConfiguration_setOrientation(_ config: OpaquePointer, _ orientation: Int32) { stub() }

func AConfiguration_setTouchscreen(_ config: OpaquePointer, _ touchscreen: Int32) { stub() }

func AConfiguration_setDensity(_ config: OpaquePointer, _ density: Int32) { stub() }

func AConfiguration_setKeyboard(_ config: OpaquePointer, _ keyboard: Int32) { stub() }

func AConfiguration_setNavigation(_ config: OpaquePointer, _ navigation: Int32) { stub() }

func AConfiguration_setKeysHidden(_ config: OpaquePointer, _ keysHidden: Int32) { stub() }

func AConfiguration_setNavHidden(_ config: OpaquePointer, _ navHidden: Int32) { stub() }

func AConfiguration_setSdkVersion(_ config: OpaquePointer, _ sdkVersion: Int32) { stub() }

func AConfiguration_setScreenSize(_ config: OpaquePointer, _ screenSize: Int32) { stub() }

func AConfiguration_setScreenLong(_ config: OpaquePointer, _ screenLong: Int32) { stub() }

func AConfiguration_setScreenRound(_ config: OpaquePointer, _ screenRound: Int32) { stub() }

func AConfiguration_setUiModeType(_ config: OpaquePointer, _ uiModeType: Int32) { stub() }

func AConfiguration_setUiModeNight(_ config: OpaquePointer, _ uiModeNight: Int32) { stub() }

func AConfiguration_setScreenWidthDp(_ config: OpaquePointer, _ value: Int32) { stub() }

func AConfiguration_setScreenHeightDp(_ config: OpaquePointer, _ value: Int32) { stub() }

func AConfiguration_setSmallestScreenWidthDp(_ config: OpaquePointer, _ value: Int32) { stub() }

func AConfiguration_setLayoutDirection(_ config: OpaquePointer, _ value: Int32) { stub() }

func AConfiguration_setGrammaticalGender(_ config: OpaquePointer, _ value: Int32) { stub() }

// MARK: - AAssetManager

func AAssetManager_open(
    _ manager: OpaquePointer,
    _ fileName: UnsafePointer<CChar>?,
    _ mode: Int32
) -> OpaquePointer? { stub() }

func AAssetManager_openDir(
    _ manager: OpaquePointer,
    _ dirName: UnsafePointer<CChar>?
) -> OpaquePointer? { stub() }

func AAssetManager_fromJava(_ environment: JNIEnvironment?, _ javaObject: jobject) -> OpaquePointer? { fatalError("stub") }

// MARK: - AAssetDir

func AAssetDir_getNextFileName(_ assetDir: OpaquePointer) -> UnsafePointer<CChar>? { stub() }

func AAssetDir_rewind(_ assetDir: OpaquePointer) { stub() }

func AAssetDir_close(_ assetDir: OpaquePointer) { stub() }

// MARK: - AAsset

func AAsset_close(_ asset: OpaquePointer) { stub() }

func AAsset_read(
    _ asset: OpaquePointer,
    _ buf: UnsafeMutableRawPointer?,
    _ count: Int
) -> Int32 { stub() }

func AAsset_seek64(
    _ asset: OpaquePointer,
    _ offset: Int64,
    _ whence: Int32
) -> Int64 { stub() }

func AAsset_getLength64(_ asset: OpaquePointer) -> Int64 { stub() }

func AAsset_getRemainingLength64(_ asset: OpaquePointer) -> Int64 { stub() }

func AAsset_getBuffer(_ asset: OpaquePointer) -> UnsafeRawPointer? { stub() }

func AAsset_isAllocated(_ asset: OpaquePointer) -> Int32 { stub() }

func AAsset_openFileDescriptor64(
    _ asset: OpaquePointer,
    _ outStart: UnsafeMutablePointer<Int64>?,
    _ outLength: UnsafeMutablePointer<Int64>?
) -> Int32 { stub() }

// MARK: - AStorageManager

func AStorageManager_new() -> OpaquePointer? { stub() }

func AStorageManager_delete(_ manager: OpaquePointer) { stub() }

func AStorageManager_mountObb(
    _ manager: OpaquePointer,
    _ filename: UnsafePointer<CChar>?,
    _ key: UnsafePointer<CChar>?,
    _ callback: (@convention(c) (UnsafePointer<CChar>?, Int32, UnsafeMutableRawPointer?) -> Void)?,
    _ data: UnsafeMutableRawPointer?
) { stub() }

func AStorageManager_unmountObb(
    _ manager: OpaquePointer,
    _ filename: UnsafePointer<CChar>?,
    _ force: Int32,
    _ callback: (@convention(c) (UnsafePointer<CChar>?, Int32, UnsafeMutableRawPointer?) -> Void)?,
    _ data: UnsafeMutableRawPointer?
) { stub() }

func AStorageManager_isObbMounted(
    _ manager: OpaquePointer,
    _ filename: UnsafePointer<CChar>?
) -> Int32 { stub() }

func AStorageManager_getMountedObbPath(
    _ manager: OpaquePointer,
    _ filename: UnsafePointer<CChar>?
) -> UnsafePointer<CChar>? { stub() }

// MARK: - AObbInfo

func AObbScanner_getObbInfo(_ filename: UnsafePointer<CChar>?) -> OpaquePointer? { stub() }

func AObbInfo_delete(_ obbInfo: OpaquePointer) { stub() }

func AObbInfo_getFlags(_ obbInfo: OpaquePointer) -> Int32 { stub() }

func AObbInfo_getPackageName(_ obbInfo: OpaquePointer) -> UnsafePointer<CChar>? { stub() }

func AObbInfo_getVersion(_ obbInfo: OpaquePointer) -> Int32 { stub() }

#endif
