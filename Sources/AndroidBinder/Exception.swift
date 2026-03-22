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

/**
 * Top level exceptions types for Android binder errors, mapping to Java
 * exceptions. Also see Parcel.java.
 */
@available(Android 29, *)
public enum Exception: Int32, Sendable, CaseIterable {

    /// SecurityException
    case security = -1

    /// BadParcelableException
    case badParcelable = -2

    /// IllegalArgumentException
    case illegalArgument = -3

    /// NullPointerException
    case nullPointer = -4

    /// IllegalStateException
    case illegalState = -5

    /// NetworkOnMainThreadException
    case networkMainThread = -6

    /// UnsupportedOperationException
    case unsupportedOperation = -7

    /// Service-specific exception.
    case serviceSpecific = -8

    /// ParcelableException
    case parcelable = -9

    /**
     * Special value indicating that the transaction
     * has failed at a low level on native binder proxies.
     */
    case transactionFailed = -129
}
