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

#if os(Android)
import AndroidFileManager

struct AndroidConfigurationTests {

    @Test func testProperties() throws {
        var config = try Configuration()

        config.mobileCountryCode = 310
        #expect(config.mobileCountryCode == 310)

        config.mobileNetworkCode = 260
        #expect(config.mobileNetworkCode == 260)

        config.languageCode = "en"
        #expect(config.languageCode == "en")

        config.countryCode = "US"
        #expect(config.countryCode == "US")

        config.orientation = .portrait
        #expect(config.orientation == .portrait)

        config.touchscreen = .finger
        #expect(config.touchscreen == .finger)

        config.density = .xHigh
        #expect(config.density == .xHigh)

        config.keyboard = .qwerty
        #expect(config.keyboard == .qwerty)

        config.navigation = .dpad
        #expect(config.navigation == .dpad)

        config.keysHidden = .hidden
        #expect(config.keysHidden == .hidden)

        config.navHidden = .hidden
        #expect(config.navHidden == .hidden)

        config.sdkVersion = 33
        #expect(config.sdkVersion == 33)

        config.screenSize = .large
        #expect(config.screenSize == .large)

        config.screenLong = .long
        #expect(config.screenLong == .long)

        config.uiModeType = .normal
        #expect(config.uiModeType == .normal)

        config.uiModeNight = .dark
        #expect(config.uiModeNight == .dark)

        config.screenWidthDp = 1080
        #expect(config.screenWidthDp == 1080)

        config.screenHeightDp = 1920
        #expect(config.screenHeightDp == 1920)

        config.smallestScreenWidthDp = 360
        #expect(config.smallestScreenWidthDp == 360)

        if #available(Android 17, *) {
            config.layoutDirection = .rightToLeft
            #expect(config.layoutDirection == .rightToLeft)
        }

        if #available(Android 30, *) {
            config.screenRound = .round
            #expect(config.screenRound == .round)
        }

        if #available(Android 34, *) {
            config.grammaticalGender = .feminine
            #expect(config.grammaticalGender == .feminine)
        }
    }

    @Test func testMatches() throws {
        // Two default configurations should match each other
        let a = try Configuration()
        let b = try Configuration()
        let defaultsMatch = a.matches(b)
        #expect(defaultsMatch)

        // A portrait configuration should match a portrait request
        var portrait = try Configuration()
        portrait.orientation = .portrait
        var requestedPortrait = try Configuration()
        requestedPortrait.orientation = .portrait
        let portraitMatch = portrait.matches(requestedPortrait)
        #expect(portraitMatch)

        // A portrait configuration should not match a landscape request
        var requestedLandscape = try Configuration()
        requestedLandscape.orientation = .landscape
        let landscapeMismatch = portrait.matches(requestedLandscape)
        #expect(!landscapeMismatch)
    }

    @Test func testDiff() throws {
        // Two default configurations should have no differences
        let a = try Configuration()
        let b = try Configuration()
        let zeroDiff = a.diff(b)
        #expect(zeroDiff == 0)

        // Configurations differing by MCC should produce a non-zero diff
        var c = try Configuration()
        c.mobileCountryCode = 310
        let mccDiff = a.diff(c)
        #expect(mccDiff != 0)

        // Multiple differing fields should each contribute to the diff mask
        var d = try Configuration()
        d.orientation = .landscape
        d.uiModeNight = .dark
        let mask = a.diff(d)
        #expect(mask != 0)
        // orientation and UI mode each set distinct bits
        let orientationBit: Int32 = 0x0100 // ACONFIGURATION_ORIENTATION
        let uiModeBit: Int32 = 0x2000 // ACONFIGURATION_UI_MODE
        #expect(mask & orientationBit != 0)
        #expect(mask & uiModeBit != 0)
    }
}
#endif
