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

extension Configuration {

    // MARK: - Orientation

    /// Screen orientation. Corresponds to `ACONFIGURATION_ORIENTATION_*`.
    public enum Orientation: Int32 {
        /// Not specified (`ACONFIGURATION_ORIENTATION_ANY`).
        case any = 0
        /// Portrait orientation (`ACONFIGURATION_ORIENTATION_PORT`).
        case portrait = 1
        /// Landscape orientation (`ACONFIGURATION_ORIENTATION_LAND`).
        case landscape = 2
    }

    // MARK: - Touchscreen

    /// Touchscreen type. Corresponds to `ACONFIGURATION_TOUCHSCREEN_*`.
    public enum Touchscreen: Int32 {
        /// Not specified (`ACONFIGURATION_TOUCHSCREEN_ANY`).
        case any = 0
        /// No touchscreen (`ACONFIGURATION_TOUCHSCREEN_NOTOUCH`).
        case none = 1
        /// Finger touchscreen (`ACONFIGURATION_TOUCHSCREEN_FINGER`).
        case finger = 3
    }

    // MARK: - Density

    /// Screen density. Corresponds to `ACONFIGURATION_DENSITY_*`.
    ///
    /// Use the named static constants for standard density buckets, or
    /// initialize with an explicit DPI value for a custom density.
    public struct Density: RawRepresentable, Equatable, Sendable {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Default density (`ACONFIGURATION_DENSITY_DEFAULT`).
        public static var `default`: Density { Density(rawValue: 0) }
        /// ~120 dpi (`ACONFIGURATION_DENSITY_LOW`).
        public static var low: Density { Density(rawValue: 120) }
        /// ~160 dpi (`ACONFIGURATION_DENSITY_MEDIUM`).
        public static var medium: Density { Density(rawValue: 160) }
        /// ~213 dpi (`ACONFIGURATION_DENSITY_TV`).
        public static var tv: Density { Density(rawValue: 213) }
        /// ~240 dpi (`ACONFIGURATION_DENSITY_HIGH`).
        public static var high: Density { Density(rawValue: 240) }
        /// ~320 dpi (`ACONFIGURATION_DENSITY_XHIGH`).
        public static var xHigh: Density { Density(rawValue: 320) }
        /// ~480 dpi (`ACONFIGURATION_DENSITY_XXHIGH`).
        public static var xxHigh: Density { Density(rawValue: 480) }
        /// ~640 dpi (`ACONFIGURATION_DENSITY_XXXHIGH`).
        public static var xxxHigh: Density { Density(rawValue: 640) }
        /// Any density (`ACONFIGURATION_DENSITY_ANY`).
        public static var any: Density { Density(rawValue: 0xfffe) }
        /// No density specified (`ACONFIGURATION_DENSITY_NONE`).
        public static var none: Density { Density(rawValue: 0xffff) }
    }

    // MARK: - Keyboard

    /// Keyboard type. Corresponds to `ACONFIGURATION_KEYBOARD_*`.
    public enum Keyboard: Int32 {
        /// Not specified (`ACONFIGURATION_KEYBOARD_ANY`).
        case any = 0
        /// No keyboard (`ACONFIGURATION_KEYBOARD_NOKEYS`).
        case none = 1
        /// QWERTY keyboard (`ACONFIGURATION_KEYBOARD_QWERTY`).
        case qwerty = 2
        /// 12-key keyboard (`ACONFIGURATION_KEYBOARD_12KEY`).
        case twelveKey = 3
    }

    // MARK: - Navigation

    /// Navigation input method. Corresponds to `ACONFIGURATION_NAVIGATION_*`.
    public enum Navigation: Int32 {
        /// Not specified (`ACONFIGURATION_NAVIGATION_ANY`).
        case any = 0
        /// No navigation input (`ACONFIGURATION_NAVIGATION_NONAV`).
        case none = 1
        /// D-pad (`ACONFIGURATION_NAVIGATION_DPAD`).
        case dpad = 2
        /// Trackball (`ACONFIGURATION_NAVIGATION_TRACKBALL`).
        case trackball = 3
        /// Scroll wheel (`ACONFIGURATION_NAVIGATION_WHEEL`).
        case wheel = 4
    }

    // MARK: - Key Availability

    /// Hardware keyboard availability. Corresponds to `ACONFIGURATION_KEYSHIDDEN_*`.
    public enum KeyAvailability: Int32 {
        /// Not specified (`ACONFIGURATION_KEYSHIDDEN_ANY`).
        case any = 0
        /// Keys are visible (`ACONFIGURATION_KEYSHIDDEN_NO`).
        case exposed = 1
        /// Keys are hidden (`ACONFIGURATION_KEYSHIDDEN_YES`).
        case hidden = 2
        /// Keys are provided by a soft keyboard (`ACONFIGURATION_KEYSHIDDEN_SOFT`).
        case soft = 3
    }

    // MARK: - Navigation Availability

    /// Hardware navigation availability. Corresponds to `ACONFIGURATION_NAVHIDDEN_*`.
    public enum NavAvailability: Int32 {
        /// Not specified (`ACONFIGURATION_NAVHIDDEN_ANY`).
        case any = 0
        /// Navigation is visible (`ACONFIGURATION_NAVHIDDEN_NO`).
        case exposed = 1
        /// Navigation is hidden (`ACONFIGURATION_NAVHIDDEN_YES`).
        case hidden = 2
    }

    // MARK: - Screen Size

    /// Screen size bucket. Corresponds to `ACONFIGURATION_SCREENSIZE_*`.
    public enum ScreenSize: Int32 {
        /// Not specified (`ACONFIGURATION_SCREENSIZE_ANY`).
        case any = 0
        /// At least ~320×426 dp (`ACONFIGURATION_SCREENSIZE_SMALL`).
        case small = 1
        /// At least ~320×470 dp (`ACONFIGURATION_SCREENSIZE_NORMAL`).
        case normal = 2
        /// At least ~480×640 dp (`ACONFIGURATION_SCREENSIZE_LARGE`).
        case large = 3
        /// At least ~720×960 dp (`ACONFIGURATION_SCREENSIZE_XLARGE`).
        case xLarge = 4
    }

    // MARK: - Screen Long

    /// Whether the screen has a long aspect ratio. Corresponds to `ACONFIGURATION_SCREENLONG_*`.
    public enum ScreenLong: Int32 {
        /// Not specified (`ACONFIGURATION_SCREENLONG_ANY`).
        case any = 0
        /// Not a long-aspect screen (`ACONFIGURATION_SCREENLONG_NO`).
        case notLong = 1
        /// Long-aspect screen (`ACONFIGURATION_SCREENLONG_YES`).
        case long = 2
    }

    // MARK: - Screen Round

    /// Whether the screen is round. Corresponds to `ACONFIGURATION_SCREENROUND_*`.
    public enum ScreenRound: Int32 {
        /// Not specified (`ACONFIGURATION_SCREENROUND_ANY`).
        case any = 0
        /// Non-round screen (`ACONFIGURATION_SCREENROUND_NO`).
        case notRound = 1
        /// Round screen (`ACONFIGURATION_SCREENROUND_YES`).
        case round = 2
    }

    // MARK: - UI Mode Type

    /// UI mode type. Corresponds to `ACONFIGURATION_UI_MODE_TYPE_*`.
    public enum UIModeType: Int32 {
        /// Not specified (`ACONFIGURATION_UI_MODE_TYPE_ANY`).
        case any = 0
        /// Normal UI mode (`ACONFIGURATION_UI_MODE_TYPE_NORMAL`).
        case normal = 1
        /// Desk dock (`ACONFIGURATION_UI_MODE_TYPE_DESK`).
        case desk = 2
        /// Car dock (`ACONFIGURATION_UI_MODE_TYPE_CAR`).
        case car = 3
        /// Television (`ACONFIGURATION_UI_MODE_TYPE_TELEVISION`).
        case television = 4
        /// Appliance with no display (`ACONFIGURATION_UI_MODE_TYPE_APPLIANCE`).
        case appliance = 5
        /// Watch (`ACONFIGURATION_UI_MODE_TYPE_WATCH`).
        case watch = 6
        /// VR headset (`ACONFIGURATION_UI_MODE_TYPE_VR_HEADSET`).
        case vrHeadset = 7
    }

    // MARK: - Night Mode

    /// Night (dark) mode setting. Corresponds to `ACONFIGURATION_UI_MODE_NIGHT_*`.
    public enum NightMode: Int32 {
        /// Not specified (`ACONFIGURATION_UI_MODE_NIGHT_ANY`).
        case any = 0
        /// Light mode (`ACONFIGURATION_UI_MODE_NIGHT_NO`).
        case light = 1
        /// Dark/night mode (`ACONFIGURATION_UI_MODE_NIGHT_YES`).
        case dark = 2
    }

    // MARK: - Layout Direction

    /// Layout direction. Corresponds to `ACONFIGURATION_LAYOUTDIR_*`.
    public enum LayoutDirection: Int32 {
        /// Not specified (`ACONFIGURATION_LAYOUTDIR_ANY`).
        case any = 0
        /// Left-to-right (`ACONFIGURATION_LAYOUTDIR_LTR`).
        case leftToRight = 1
        /// Right-to-left (`ACONFIGURATION_LAYOUTDIR_RTL`).
        case rightToLeft = 2
    }

    // MARK: - Grammatical Gender

    /// Grammatical gender for locale-sensitive string inflection.
    /// Corresponds to `ACONFIGURATION_GRAMMATICAL_GENDER_*`.
    public enum GrammaticalGender: Int32 {
        /// Not specified (`ACONFIGURATION_GRAMMATICAL_GENDER_ANY`).
        case any = 0
        /// Neuter gender (`ACONFIGURATION_GRAMMATICAL_GENDER_NEUTER`).
        case neuter = 1
        /// Feminine gender (`ACONFIGURATION_GRAMMATICAL_GENDER_FEMININE`).
        case feminine = 2
        /// Masculine gender (`ACONFIGURATION_GRAMMATICAL_GENDER_MASCULINE`).
        case masculine = 3
    }
}
