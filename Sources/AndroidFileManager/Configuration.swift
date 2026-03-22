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
    init() {
        guard let pointer = AConfiguration_new() else {
            fatalError("AConfiguration_new() failed")
        }
        self.init(pointer: pointer)
    }

    /// Creates a configuration populated from the current asset manager state.
    init(assetManager: borrowing AssetManager) {
        self.init()
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

    /// Screen orientation.
    var orientation: Orientation {
        get { Orientation(rawValue: AConfiguration_getOrientation(pointer)) ?? .any }
        set { AConfiguration_setOrientation(pointer, newValue.rawValue) }
    }

    /// Touchscreen type.
    var touchscreen: Touchscreen {
        get { Touchscreen(rawValue: AConfiguration_getTouchscreen(pointer)) ?? .any }
        set { AConfiguration_setTouchscreen(pointer, newValue.rawValue) }
    }

    /// Screen density. Use ``Density/other(_:)`` for explicit DPI values
    /// not covered by a named bucket.
    var density: Density {
        get { Density(rawValue: AConfiguration_getDensity(pointer)) }
        set { AConfiguration_setDensity(pointer, newValue.rawValue) }
    }

    /// Keyboard type.
    var keyboard: Keyboard {
        get { Keyboard(rawValue: AConfiguration_getKeyboard(pointer)) ?? .any }
        set { AConfiguration_setKeyboard(pointer, newValue.rawValue) }
    }

    /// Navigation input method.
    var navigation: Navigation {
        get { Navigation(rawValue: AConfiguration_getNavigation(pointer)) ?? .any }
        set { AConfiguration_setNavigation(pointer, newValue.rawValue) }
    }

    /// Hardware keyboard availability.
    var keysHidden: KeyAvailability {
        get { KeyAvailability(rawValue: AConfiguration_getKeysHidden(pointer)) ?? .any }
        set { AConfiguration_setKeysHidden(pointer, newValue.rawValue) }
    }

    /// Hardware navigation availability.
    var navHidden: NavAvailability {
        get { NavAvailability(rawValue: AConfiguration_getNavHidden(pointer)) ?? .any }
        set { AConfiguration_setNavHidden(pointer, newValue.rawValue) }
    }

    /// Minimum Android SDK (API) version required.
    var sdkVersion: Int32 {
        get { AConfiguration_getSdkVersion(pointer) }
        set { AConfiguration_setSdkVersion(pointer, newValue) }
    }

    /// Screen size bucket.
    var screenSize: ScreenSize {
        get { ScreenSize(rawValue: AConfiguration_getScreenSize(pointer)) ?? .any }
        set { AConfiguration_setScreenSize(pointer, newValue.rawValue) }
    }

    /// Whether the screen has a long aspect ratio.
    var screenLong: ScreenLong {
        get { ScreenLong(rawValue: AConfiguration_getScreenLong(pointer)) ?? .any }
        set { AConfiguration_setScreenLong(pointer, newValue.rawValue) }
    }

    /// Whether the screen is round.
    @available(Android 30, *)
    var screenRound: ScreenRound {
        get { ScreenRound(rawValue: AConfiguration_getScreenRound(pointer)) ?? .any }
        //set { AConfiguration_setScreenRound(pointer, newValue.rawValue) }
    }

    /// UI mode type (car, desk, television, etc.).
    var uiModeType: UIModeType {
        get { UIModeType(rawValue: AConfiguration_getUiModeType(pointer)) ?? .any }
        set { AConfiguration_setUiModeType(pointer, newValue.rawValue) }
    }

    /// Night/dark mode setting.
    var uiModeNight: NightMode {
        get { NightMode(rawValue: AConfiguration_getUiModeNight(pointer)) ?? .any }
        set { AConfiguration_setUiModeNight(pointer, newValue.rawValue) }
    }

    /// Current screen width in dp units, or 0 if not set.
    var screenWidthDp: Int32 {
        get { AConfiguration_getScreenWidthDp(pointer) }
        set { AConfiguration_setScreenWidthDp(pointer, newValue) }
    }

    /// Current screen height in dp units, or 0 if not set.
    var screenHeightDp: Int32 {
        get { AConfiguration_getScreenHeightDp(pointer) }
        set { AConfiguration_setScreenHeightDp(pointer, newValue) }
    }

    /// Smallest screen dimension in dp units, or 0 if not set.
    var smallestScreenWidthDp: Int32 {
        get { AConfiguration_getSmallestScreenWidthDp(pointer) }
        set { AConfiguration_setSmallestScreenWidthDp(pointer, newValue) }
    }

    /// Layout direction.
    @available(Android 17, *)
    var layoutDirection: LayoutDirection {
        get { LayoutDirection(rawValue: AConfiguration_getLayoutDirection(pointer)) ?? .any }
        set { AConfiguration_setLayoutDirection(pointer, newValue.rawValue) }
    }

    /// Grammatical gender for locale-sensitive string inflection.
    @available(Android 34, *)
    var grammaticalGender: GrammaticalGender {
        get { GrammaticalGender(rawValue: AConfiguration_getGrammaticalGender(pointer)) ?? .any }
        set { AConfiguration_setGrammaticalGender(pointer, newValue.rawValue) }
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
