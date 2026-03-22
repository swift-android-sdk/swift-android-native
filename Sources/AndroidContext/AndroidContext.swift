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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
#if canImport(Android)
import Android
#elseif canImport(Darwin)
import func Darwin.getenv
#elseif canImport(Glibc)
import func Glibc.getenv
#endif
import SwiftJavaJNICore
public import AndroidAssetManager

/// A native reference to
/// [android.content.Context](https://developer.android.com/reference/android/content/Context)
//@available(macOS, unavailable)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public final class AndroidContext: @unchecked Sendable {
    /// The JNI signature for the method to invoke to obtain the global Context.
    /// This can be manually changed before initialization to a different signature.
    /// It must be a zero-argument static fuction that returns an instance of `android.content.Context`.
    ///
    /// The default value of the factory will be the value of the `SWIFT_ANDROID_CONTEXT_FACTORY` environment variable,
    /// and if unset, will fall back to `android.app.ActivityThread.currentApplication()Landroid/app/Application;`.
    public static var contextFactory: String {
        getenv("SWIFT_ANDROID_CONTEXT_FACTORY").flatMap({ String(cString: $0) }) ?? "android.app.ActivityThread.currentApplication()Landroid/app/Application;"
    }

    /// A global pointer to the application context, in case the application environment wants to initialize it directly without going through the factory method.
    public nonisolated(unsafe) static var contextPointer: jobject? = nil

    /// The underlying JNI object pointer for this context.
    public let pointer: jobject

    /// The JNI environment used by this context.
    private let env: JNIEnvironment

    /// Initialize from an existing JNI object pointer and environment.
    internal init(pointer: jobject, env: JNIEnvironment) {
        self.pointer = pointer
        self.env = env
    }

    /// Creates an `AndroidContext` from a Java `android.content.Context` object.
    ///
    /// - Parameters:
    ///   - javaObject: A JNI reference to an `android.content.Context` (or subclass).
    ///   - environment: The JNI environment for the current thread.
    /// - Returns: An `AndroidContext` wrapping the given Java object.
    public static func fromJava(_ javaObject: jobject, environment: JNIEnvironment) -> AndroidContext {
        AndroidContext(pointer: javaObject, env: environment)
    }

    /// Sets a pre-initialized Android context directly, bypassing the automatic JVM and context
    /// lookup performed by the `application` accessor.
    ///
    /// Call this method early in your application's lifecycle — for example, from a `JNI_OnLoad`
    /// function or an `ANativeActivity` callback — before any code accesses `AndroidContext.application`.
    /// Once the shared context is set, `application` will return it immediately without attempting to
    /// locate the JVM or invoke the `contextFactory` reflective lookup.
    ///
    /// - Parameter context: A JNI `jobject` reference to an `android.content.Context` (or subclass
    ///   such as `android.app.Application`). The caller is responsible for ensuring this reference
    ///   remains valid for the lifetime of the process (typically a global ref).
    /// - Parameter env: The JNI environment for the current thread.
    public static func setSharedContext(_ context: jobject, env: JNIEnvironment) {
        sharedContext = AndroidContext(pointer: context, env: env)
    }

    /// A manually provided shared context, set via `setSharedContext(_:env:)`.
    private nonisolated(unsafe) static var sharedContext: AndroidContext? = nil

    /// Returns the application context.
    public static var application: AndroidContext {
        get throws(AndroidContextError) {
            if let sharedContext = sharedContext {
                return sharedContext
            }
            return try applicationContext.get()
        }
    }

    /// Obtain the global application context by checking whether the static `contextPointer` is set,
    /// and if not, using the `contextFactory` string to reflectively look up the global context.
    private static let applicationContext: Result<AndroidContext, AndroidContextError> = {
        let jvm: JavaVirtualMachine
        let env: JNIEnvironment
        do {
            jvm = try JavaVirtualMachine.shared()
            env = try jvm.environment()
        } catch {
            return .failure(.virtualMachine(error))
        }
        let jni: JNINativeInterface = env.pointee!.pointee

        // if we have provided a manual context jobject, then we just use that and skip trying to access the factory
        if let contextPointer = contextPointer {
            return .success(AndroidContext(pointer: contextPointer, env: env))
        }

        // alternative fallback mechanism:
        //contextFactory = "android.app.AppGlobals.getInitialApplication()Landroid/app/Application;"

        // get the first part of the contextFactory parameter: android.app.ActivityThread
        let contextParts = contextFactory.split(separator: ".")
        let contextType = contextParts.dropLast().joined(separator: ".")
        let contextRemainder = contextParts.last ?? ""

        // get the second part of the contextFactory parameter: currentApplication()Landroid/app/Application;
        let contextFunctionParts = contextRemainder.split(separator: "(")
        if contextFunctionParts.count != 2 {
            return .failure(.invalidSignature(contextFactory))
        }

        let contextMethod = "" + contextFunctionParts[0]
        let contextSig = "(" + contextFunctionParts[1]

        // Convert class name from dot notation to slash notation for JNI
        let jniClassName = contextType.split(separator: ".").joined(separator: "/")

        guard let cls: jclass = jni.FindClass(env, jniClassName) else {
            return .failure(.classNotFound(contextType))
        }

        guard let mth: jmethodID = jni.GetStaticMethodID(env, cls, contextMethod, contextSig) else {
            return .failure(.methodNotFound(contextMethod))
        }

        guard let ctx: jobject = jni.CallStaticObjectMethodA(env, cls, mth, []) else {
            return .failure(.nullValueForMethod(contextMethod))
        }

        return .success(AndroidContext(pointer: ctx, env: env))
    }()

    /// The `AndroidAssetManager` for this context
    public var assetManager: AssetManager {
        let jni: JNINativeInterface = env.pointee!.pointee

        // Call context.getAssets() to get the Java AssetManager
        let contextClass: jclass = jni.GetObjectClass(env, pointer)!
        let getAssetsID: jmethodID = jni.GetMethodID(env, contextClass, "getAssets", "()Landroid/content/res/AssetManager;")!
        let assetManagerObj: jobject = jni.CallObjectMethodA(env, pointer, getAssetsID, [])!

        return AssetManager.fromJava(assetManagerObj, environment: env)!
    }

    /// Returns the package name for the current context
    public func getPackageName() throws(AndroidContextError) -> String? {
        let jni: JNINativeInterface = env.pointee!.pointee

        let contextClass: jclass = jni.GetObjectClass(env, pointer)!
        guard let getPackageNameID: jmethodID = jni.GetMethodID(env, contextClass, "getPackageName", "()Ljava/lang/String;") else {
            throw AndroidContextError.methodNotFound("getPackageName")
        }

        guard let javaString: jobject = jni.CallObjectMethodA(env, pointer, getPackageNameID, []) else {
            return nil
        }

        // Convert Java String to Swift String
        guard let utf8Chars = jni.GetStringUTFChars(env, javaString, nil) else {
            return nil
        }
        let result = String(cString: utf8Chars)
        jni.ReleaseStringUTFChars(env, javaString, utf8Chars)
        return result
    }
}
