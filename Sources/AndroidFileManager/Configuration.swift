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

#if os(Android)
import Android
import CAndroidNDK
#endif

/// Wrapper around Android NDK `AConfiguration`.
///
/// Provides access to device configuration values such as locale, screen properties,
/// input methods, and UI mode. Use ``init(assetManager:)`` to populate from the
/// current environment, or ``init()`` to create an empty configuration you fill manually.
public struct Configuration: ~Copyable {

    internal let pointer: OpaquePointer

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    deinit {
        AConfiguration_delete(pointer)
    }
}

// MARK: - Initialization

public extension Configuration {

    /// Creates a new, empty configuration object.
    init() throws(AndroidFileManagerError) {
        guard let pointer = AConfiguration_new() else {
            throw .invalidConfiguration
        }
        self.init(pointer: pointer)
    }

    /// Creates a configuration populated from the current asset manager state.
    init(assetManager: borrowing AssetManager) throws(AndroidFileManagerError) {
        try self.init()
        AConfiguration_fromAssetManager(pointer, assetManager.pointer)
    }
}

// MARK: - Methods

public extension Configuration {

    /// Copies all values from `other` into this configuration.
    func copy(from other: borrowing Configuration) {
        AConfiguration_copy(pointer, other.pointer)
    }

    /// Returns a bitmask of `ACONFIGURATION_*` flags indicating which fields
    /// differ between this configuration and `other`.
    func diff(_ other: borrowing Configuration) -> Int32 {
        AConfiguration_diff(pointer, other.pointer)
    }

    /// Returns `true` if this configuration is a valid match for `requested`.
    ///
    /// A configuration matches when every field it specifies is compatible with
    /// the corresponding field in `requested`.
    func matches(_ requested: borrowing Configuration) -> Bool {
        AConfiguration_match(pointer, requested.pointer) != 0
    }

    /// Returns `true` if this configuration is a better match for `requested` than `base` is.
    ///
    /// Both `self` and `base` must already satisfy ``matches(_:)`` for `requested`.
    func isBetter(than base: borrowing Configuration, requested: borrowing Configuration) -> Bool {
        AConfiguration_isBetterThan(base.pointer, pointer, requested.pointer) != 0
    }
}

// MARK: - Properties

public extension Configuration {

    /// Mobile country code, or 0 if not set. Corresponds to `ACONFIGURATION_MCC`.
    var mobileCountryCode: Int32 {
        get { AConfiguration_getMcc(pointer) }
        set { AConfiguration_setMcc(pointer, newValue) }
    }

    /// Mobile network code, or 0 if not set. Corresponds to `ACONFIGURATION_MNC`.
    var mobileNetworkCode: Int32 {
        get { AConfiguration_getMnc(pointer) }
        set { AConfiguration_setMnc(pointer, newValue) }
    }

    /// ISO 639-1 language code, or `nil` if not set.
    var languageCode: String? {
        get {
            var out = [CChar](repeating: 0, count: 2)
            AConfiguration_getLanguage(pointer, &out)
            return decodeCode(out)
        }
        set {
            newValue?.withCString { AConfiguration_setLanguage(pointer, $0) }
                ?? AConfiguration_setLanguage(pointer, nil)
        }
    }

    /// ISO 3166-1 alpha-2 region/country code, or `nil` if not set.
    var countryCode: String? {
        get {
            var out = [CChar](repeating: 0, count: 2)
            AConfiguration_getCountry(pointer, &out)
            return decodeCode(out)
        }
        set {
            newValue?.withCString { AConfiguration_setCountry(pointer, $0) }
                ?? AConfiguration_setCountry(pointer, nil)
        }
    }

    /// Screen orientation. One of the `ACONFIGURATION_ORIENTATION_*` constants.
    var orientation: Int32 {
        get { AConfiguration_getOrientation(pointer) }
        set { AConfiguration_setOrientation(pointer, newValue) }
    }

    /// Touchscreen type. One of the `ACONFIGURATION_TOUCHSCREEN_*` constants.
    var touchscreen: Int32 {
        get { AConfiguration_getTouchscreen(pointer) }
        set { AConfiguration_setTouchscreen(pointer, newValue) }
    }

    /// Screen density in DPI. One of the `ACONFIGURATION_DENSITY_*` constants,
    /// or an explicit DPI value.
    var density: Int32 {
        get { AConfiguration_getDensity(pointer) }
        set { AConfiguration_setDensity(pointer, newValue) }
    }

    /// Keyboard type. One of the `ACONFIGURATION_KEYBOARD_*` constants.
    var keyboard: Int32 {
        get { AConfiguration_getKeyboard(pointer) }
        set { AConfiguration_setKeyboard(pointer, newValue) }
    }

    /// Navigation method. One of the `ACONFIGURATION_NAVIGATION_*` constants.
    var navigation: Int32 {
        get { AConfiguration_getNavigation(pointer) }
        set { AConfiguration_setNavigation(pointer, newValue) }
    }

    /// Keyboard availability. One of the `ACONFIGURATION_KEYSHIDDEN_*` constants.
    var keysHidden: Int32 {
        get { AConfiguration_getKeysHidden(pointer) }
        set { AConfiguration_setKeysHidden(pointer, newValue) }
    }

    /// Navigation availability. One of the `ACONFIGURATION_NAVHIDDEN_*` constants.
    var navHidden: Int32 {
        get { AConfiguration_getNavHidden(pointer) }
        set { AConfiguration_setNavHidden(pointer, newValue) }
    }

    /// Minimum Android SDK (API) version required. Corresponds to `ACONFIGURATION_VERSION`.
    var sdkVersion: Int32 {
        get { AConfiguration_getSdkVersion(pointer) }
        set { AConfiguration_setSdkVersion(pointer, newValue) }
    }

    /// Screen size bucket. One of the `ACONFIGURATION_SCREENSIZE_*` constants.
    var screenSize: Int32 {
        get { AConfiguration_getScreenSize(pointer) }
        set { AConfiguration_setScreenSize(pointer, newValue) }
    }

    /// Whether the screen is long. One of the `ACONFIGURATION_SCREENLONG_*` constants.
    var screenLong: Int32 {
        get { AConfiguration_getScreenLong(pointer) }
        set { AConfiguration_setScreenLong(pointer, newValue) }
    }

    /// Whether the screen is round. One of the `ACONFIGURATION_SCREENROUND_*` constants.
    var screenRound: Int32 {
        get { AConfiguration_getScreenRound(pointer) }
        set { AConfiguration_setScreenRound(pointer, newValue) }
    }

    /// UI mode type (car, desk, television, etc.). One of the `ACONFIGURATION_UI_MODE_TYPE_*` constants.
    var uiModeType: Int32 {
        get { AConfiguration_getUiModeType(pointer) }
        set { AConfiguration_setUiModeType(pointer, newValue) }
    }

    /// Night mode. One of the `ACONFIGURATION_UI_MODE_NIGHT_*` constants.
    var uiModeNight: Int32 {
        get { AConfiguration_getUiModeNight(pointer) }
        set { AConfiguration_setUiModeNight(pointer, newValue) }
    }

    /// Current screen width in dp units, or `ACONFIGURATION_SCREEN_WIDTH_DP_ANY` if not set.
    var screenWidthDp: Int32 {
        get { AConfiguration_getScreenWidthDp(pointer) }
        set { AConfiguration_setScreenWidthDp(pointer, newValue) }
    }

    /// Current screen height in dp units, or `ACONFIGURATION_SCREEN_HEIGHT_DP_ANY` if not set.
    var screenHeightDp: Int32 {
        get { AConfiguration_getScreenHeightDp(pointer) }
        set { AConfiguration_setScreenHeightDp(pointer, newValue) }
    }

    /// Smallest screen dimension in dp units, or `ACONFIGURATION_SMALLEST_SCREEN_WIDTH_DP_ANY` if not set.
    var smallestScreenWidthDp: Int32 {
        get { AConfiguration_getSmallestScreenWidthDp(pointer) }
        set { AConfiguration_setSmallestScreenWidthDp(pointer, newValue) }
    }

    /// Layout direction. One of the `ACONFIGURATION_LAYOUTDIR_*` constants.
    var layoutDirection: Int32 {
        get { AConfiguration_getLayoutDirection(pointer) }
        set { AConfiguration_setLayoutDirection(pointer, newValue) }
    }

    /// Grammatical gender for locale-sensitive inflection.
    /// One of the `ACONFIGURATION_GRAMMATICAL_GENDER_*` constants.
    var grammaticalGender: Int32 {
        get { AConfiguration_getGrammaticalGender(pointer) }
        set { AConfiguration_setGrammaticalGender(pointer, newValue) }
    }
}

// MARK: - Private

private extension Configuration {

    func decodeCode(_ raw: [CChar]) -> String? {
        guard raw.count >= 2 else { return nil }
        let b0 = UInt8(bitPattern: raw[0])
        let b1 = UInt8(bitPattern: raw[1])
        guard b0 != 0 || b1 != 0 else {
            return nil
        }
        let bytes = b1 == 0 ? [b0] : [b0, b1]
        return String(decoding: bytes, as: UTF8.self)
    }
}
