// swift-tools-version: 6.2
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
import PackageDescription
import class Foundation.FileManager
import class Foundation.ProcessInfo

let android = Context.environment["TARGET_OS_ANDROID"] ?? "0" != "0"

// Override JNI package
let swiftJavaJNICoreDep: Package.Dependency
if let localPath = Context.environment["SWIFT_JAVA_JNI_CORE_PATH"] {
    swiftJavaJNICoreDep = .package(path: localPath)
} else {
    swiftJavaJNICoreDep = .package(url: "https://github.com/swiftlang/swift-java-jni-core", from: "0.3.0")
}

// Get NDK version from command line
let ndkVersion = ProcessInfo.processInfo.environment["ANDROID_NDK_VERSION"].flatMap { UInt($0) } ?? 27
let ndkVersionDefine = SwiftSetting.define("ANDROID_NDK_VERSION_" + ndkVersion.description)

// Get Android API version
let sdkVersion = ProcessInfo.processInfo.environment["ANDROID_SDK_VERSION"].flatMap { UInt($0) } ?? 28
let sdkVersionDefine = SwiftSetting.define("ANDROID_SDK_VERSION_" + sdkVersion.description)

// Conditionally enable features
let ndkBinder = sdkVersion >= 29 // binder_ndk Requires API 29

let package = Package(
    name: "swift-android-native",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .macCatalyst(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AndroidNative", targets: ["AndroidNative"]),
        .library(name: "AndroidContext", targets: ["AndroidContext"]),
        .library(name: "AndroidAssetManager", targets: ["AndroidAssetManager"]),
        .library(name: "AndroidLogging", targets: ["AndroidLogging"]),
        .library(name: "AndroidLooper", targets: ["AndroidLooper"]),
        .library(name: "AndroidChoreographer", targets: ["AndroidChoreographer"]),
        .library(name: "AndroidManifest", targets: ["AndroidManifest"]),
        .library(name: "AndroidInput", targets: ["AndroidInput"]),
        .library(name: "AndroidHardware", targets: ["AndroidHardware"]),
    ],
    dependencies: [
        swiftJavaJNICoreDep
    ],
    targets: [
        .target(
            name: "CAndroidNDK",
            linkerSettings: [
                .linkedLibrary("android", .when(platforms: [.android])),
                .linkedLibrary("log", .when(platforms: [.android])),
            ]),
        .target(name: "ConcurrencyRuntimeC"),
        .target(
            name: "AndroidSystem",
            dependencies: [
                .target(name: "CAndroidNDK", condition: .when(platforms: [.android]))
            ],
            swiftSettings: [
                .define("SYSTEM_PACKAGE_DARWIN", .when(platforms: [.macOS, .macCatalyst, .iOS, .watchOS, .tvOS, .visionOS])),
                .define("SYSTEM_PACKAGE"),
            ]),
        .testTarget(
            name: "AndroidSystemTests",
            dependencies: [
                "AndroidSystem"
            ]),
        .target(
            name: "AndroidAssetManager",
            dependencies: [
                .product(name: "SwiftJavaJNICore", package: "swift-java-jni-core"),
                .target(name: "CAndroidNDK", condition: .when(platforms: [.android])),
            ],
            swiftSettings: [
                ndkVersionDefine,
                sdkVersionDefine,
            ]),
        .testTarget(
            name: "AndroidAssetManagerTests",
            dependencies: [
                "AndroidAssetManager"
            ]),
        .target(
            name: "AndroidContext",
            dependencies: [
                "AndroidAssetManager",
                .product(name: "SwiftJavaJNICore", package: "swift-java-jni-core"),
            ]),
        .testTarget(
            name: "AndroidContextTests",
            dependencies: [
                "AndroidContext"
            ]),
        .target(
            name: "AndroidLogging",
            dependencies: [
                "AndroidSystem"
            ]),
        .testTarget(
            name: "AndroidLoggingTests",
            dependencies: [
                "AndroidLogging"
            ]),
        .target(
            name: "AndroidLooper",
            dependencies: [
                "AndroidSystem",
                "AndroidLogging",
                "ConcurrencyRuntimeC",
            ],
            swiftSettings: [
                ndkVersionDefine,
                sdkVersionDefine,
            ]),
        .testTarget(
            name: "AndroidLooperTests",
            dependencies: [
                "AndroidLooper"
            ]),
        .target(
            name: "AndroidChoreographer",
            dependencies: [
                "AndroidSystem",
                "AndroidLogging",
            ],
            swiftSettings: [
                ndkVersionDefine,
                sdkVersionDefine,
            ]),
        .testTarget(
            name: "AndroidChoreographerTests",
            dependencies: [
                "AndroidChoreographer"
            ]),

        .target(
            name: "AndroidManifest",
            dependencies: [
                "CAndroidNDK"
            ],
            swiftSettings: [
                ndkVersionDefine,
                sdkVersionDefine,
            ],
            linkerSettings: [
                .linkedLibrary("android", .when(platforms: [.android]))
            ]
        ),
        .target(
            name: "AndroidInput",
            dependencies: [
                "CAndroidNDK",
                "AndroidLooper",
            ],
            swiftSettings: [
                ndkVersionDefine,
                sdkVersionDefine,
            ],
            linkerSettings: [
                .linkedLibrary("android", .when(platforms: [.android]))
            ]
        ),
        .target(
            name: "AndroidHardware",
            dependencies: [
                "CAndroidNDK",
                "AndroidLooper",
            ],
            swiftSettings: [
                ndkVersionDefine,
                sdkVersionDefine,
            ],
            linkerSettings: [
                .linkedLibrary("android", .when(platforms: [.android]))
            ]
        ),
        .target(
            name: "AndroidNative",
            dependencies: [
                .product(name: "SwiftJavaJNICore", package: "swift-java-jni-core"),
                "AndroidAssetManager",
                "AndroidLogging",
                "AndroidLooper",
                "AndroidChoreographer",
            ]),
        .testTarget(
            name: "AndroidNativeTests",
            dependencies: [
                "AndroidNative"
            ], resources: [.embedInCode("Resources/sample_resource.txt")]),
    ]
)

if android {
    // add compatibility import from OSLog to AndroidLogging
    package.targets += [.target(name: "OSLog", dependencies: ["AndroidLogging"])]
    package.targets.first(where: { $0.name == "AndroidLoggingTests" })?.dependencies += [.target(name: "OSLog")]
}

if ndkBinder {
    // Add the binder target
    let binderTarget = Target.target(
        name: "AndroidBinder",
        dependencies: [
            "CAndroidNDK"
        ],
        swiftSettings: [
            ndkVersionDefine,
            sdkVersionDefine,
        ],
        linkerSettings: [
            .linkedLibrary("binder_ndk", .when(platforms: [.android]))
        ]
    )
    package.targets.append(binderTarget)

    // Add the binder product
    let binderProduct = Product.library(
        name: "AndroidBinder",
        targets: ["AndroidBinder"]
    )
    package.products.append(binderProduct)
}
