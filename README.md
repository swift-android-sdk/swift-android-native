# SwiftAndroidNative

This package provides a Swift interface to various
Android [NDK APIs](https://developer.android.com/ndk/reference)
and utilities to integrate Swift Foundation with the Android environment.

## Requirements

- Swift 6
- [Swift Android Toolchain and SDK](https://github.com/skiptools/swift-android-toolchain)

## Installation

### Swift Package Manager

Add the package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/skiptools/swift-android-native.git", from: "1.0.0")
]
```

# JNI Dependencies and SwiftJava Interoperability

This package depends only on [swiftlang/swift-java-jni-core](https://github.com/swiftlang/swift-java-jni-core),
a lightweight module that provides the JNI type definitions (`jobject`, `jclass`, `JNIEnvironment`, etc.),
the `JavaVirtualMachine` lifecycle manager, and the raw `JNINativeInterface` function table.
It does *not* depend on the full [swiftlang/swift-java](https://github.com/swiftlang/swift-java) bridge
or its higher-level abstractions (`JavaObject`, `JavaClass`, generated Java-to-Swift wrappers, etc.).

This means SwiftAndroidNative can be used in projects that only need direct JNI access
without pulling in the larger swift-java dependency graph.

However, SwiftAndroidNative is designed to optionally interoperate with swift-java.
Because both packages share the same underlying JNI types from swift-java-jni-core,
a `jobject` obtained through SwiftAndroidNative (such as `AndroidContext.pointer`) can be
passed directly to swift-java bridged APIs, and vice versa. For example, a context
`jobject` returned by a swift-java generated bridge class can be handed to
`AndroidContext.setSharedContext(_:env:)`, and an `AndroidContext.pointer` can be wrapped
in a swift-java `JavaObjectHolder` for use with generated Java class bindings.

If your project uses swift-java, add it as a separate dependency alongside swift-android-native;
the two will share the same `JavaVirtualMachine` instance and JNI environment without conflict.


# AndroidLogging

This module provides a Logger API for native Swift on Android compatible with
the [OSLog Logger](https://developer.apple.com/documentation/os/logger)
for Darwin platforms.

## Installation

### Swift Package Manager

Add the `AndroidLogging` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidLogging", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```

## Usage

### Example

This example will use the system `OSLog` on Darwin platforms and `AndroidLogging` on Android
to provide common logging functionality across operating systems:

```swift
#if canImport(Darwin)
import OSLog
#elseif os(Android)
import AndroidLogging
#endif
    
let logger = Logger(subsystem: "Subsystem", category: "Category")

logger.info("Hello Android logcat!")
```

### Viewing Logs

Android log messages for connected devices and emulators
can be viewed from the Terminal using the
[`adb logcat`](https://developer.android.com/tools/logcat) command.
For example, to view only the log message in the example above, you can run:

```
$ adb logcat '*:S' 'Subsystem/Category:I'

10-27 15:53:12.768 22599 22664 I Subsystem/Category: Hello Android logcat!
```

[Android Studio](https://developer.android.com/studio/debug/logcat) provides the ability to
 graphically view and filter log messages, as do most other Android IDEs.

## Internals

### Implementation details

The `Logger` functions will forward messages to the NDK
[__android_log_write](https://developer.android.com/ndk/reference/group/logging#group___logging_1ga32a7173b092ec978b50490bd12ee523b)
function.

### Limitations

- `OSLogMessage` is simply a typealias to `Swift.String`, and does not implement any of the [redaction features](https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code#3665948) of the Darwin version.


# AndroidContext

This module provides a minimal wrapper for [android.content.Context](https://developer.android.com/reference/android/content/Context)
that uses raw JNI calls (via [SwiftJavaJNICore](https://github.com/swiftlang/swift-java-jni-core))
to bridge into the global application context.

## Installation

Add the `AndroidContext` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidContext", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```

## Usage

```swift
let context = try AndroidContext.application
let packageName = try context.getPackageName()
```

## Bootstrapping the Context

The recommended way to initialize `AndroidContext` is to call `setSharedContext(_:env:)`
as early as possible — before any code accesses `AndroidContext.application`. This avoids
the automatic JVM lookup and reflective factory call entirely, giving you full control over
how the context is provided.

### From `JNI_OnLoad`

If your Swift code is loaded as a shared library by Java (e.g. via `System.loadLibrary`),
implement the standard `JNI_OnLoad` entry point. The `JavaVM` pointer gives you a
`JNIEnvironment`, and you can then look up the application context:

```swift
import SwiftJavaJNICore
import AndroidContext

@_cdecl("JNI_OnLoad")
public func JNI_OnLoad(_ jvm: UnsafeMutablePointer<JavaVM?>, _ reserved: UnsafeMutableRawPointer?) -> jint {
    // Adopt the JVM so SwiftJavaJNICore knows about it
    let vm = JavaVirtualMachine(adoptingJVM: jvm)
    JavaVirtualMachine.setSharedJVM(vm)
    let env = try! vm.environment()
    let jni = env.pointee!.pointee

    // Look up the application context via ActivityThread
    let cls = jni.FindClass(env, "android/app/ActivityThread")!
    let mid = jni.GetStaticMethodID(env, cls, "currentApplication", "()Landroid/app/Application;")!
    let app = jni.CallStaticObjectMethodA(env, cls, mid, [])!
    let globalRef = jni.NewGlobalRef(env, app)! // prevent GC

    AndroidContext.setSharedContext(globalRef, env: env)
    return jint(JNI_VERSION_1_6)
}
```

### From SwiftJava / swift-java bridged code

If you are using the full [swift-java](https://github.com/swiftlang/swift-java) bridge,
the JVM is already set up for you. You can obtain the environment from
`JavaVirtualMachine.shared()` and pass in a context `jobject` from the bridged Java side:

```swift
let jvm = try JavaVirtualMachine.shared()
let env = try jvm.environment()
AndroidContext.setSharedContext(someContextJobject, env: env)
```

### From an `ANativeActivity`

If your application uses an NDK [ANativeActivity](https://developer.android.com/ndk/reference/struct/a-native-activity),
you can set the context pointer directly using the (misnamed) [`clazz`](https://developer.android.com/ndk/reference/struct/a-native-activity#struct_a_native_activity_1abbde1ec6b9af24c517a604f0d401b274) pointer:

```swift
let nativeActivity: ANativeActivity = …
AndroidContext.contextPointer = nativeActivity.clazz
let context = try AndroidContext.application
```

### Automatic fallback

If `setSharedContext` is never called and `contextPointer` is not set,
`AndroidContext.application` will attempt to locate the JVM automatically using
`JavaVirtualMachine.shared()` and then reflectively invoke the factory method
`android.app.ActivityThread.currentApplication()` to obtain the global context.
This can be overridden by setting the `SWIFT_ANDROID_CONTEXT_FACTORY` environment
variable to a different static accessor before the first access:

```swift
setenv("SWIFT_ANDROID_CONTEXT_FACTORY", "android.app.AppGlobals.getInitialApplication()Landroid/app/Application;", 1)
let context = try AndroidContext.application
```


# AndroidAssetManager

This module provides an [AssetManager](https://developer.android.com/ndk/reference/group/asset) API for native Swift on Android.

## Installation

### Swift Package Manager

Add the `AndroidAssetManager` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidAssetManager", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```


# AndroidChoreographer

This module provides a [Choreographer](https://developer.android.com/ndk/reference/group/choreographer) API for native Swift on Android.

## Installation

### Swift Package Manager

Add the `AndroidChoreographer` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidChoreographer", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```


# AndroidLooper

This module provides a [Looper](https://developer.android.com/ndk/reference/group/looper) API for native Swift on Android.

## Installation

### Swift Package Manager

Add the `AndroidLooper` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidLooper", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```

# AndroidManifest

This module provides access to Android [permission APIs](https://developer.android.com/ndk/reference/group/permission) for native Swift on Android.

## Installation

### Swift Package Manager

Add the `AndroidManifest` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidManifest", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```

## Usage

```swift
import AndroidManifest

// Check whether the app has been granted a permission
if Permission.readExternalStorage.isGranted {
    // access storage
}

// Check with explicit PID/UID (requires Android 31+)
let status = try Permission.camera.check()
```


# AndroidInput

This module provides an [Input](https://developer.android.com/ndk/reference/group/input) API for native Swift on Android,
including input queues, input events, game controller state, and key codes.

## Installation

### Swift Package Manager

Add the `AndroidInput` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidInput", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```

## Usage

```swift
import AndroidInput
import AndroidLooper

let looper = Looper.forThread()
inputQueue.attachLooper(looper, identifier: 1, callback: nil, data: nil)

var event: InputEvent?
if inputQueue.hasEvents() > 0 {
    inputQueue.getEvent(&event)
    // handle event
    if let event {
        inputQueue.finishEvent(event, handled: true)
    }
}
```


# AndroidHardware

This module provides a [Sensor](https://developer.android.com/ndk/reference/group/sensor) API for native Swift on Android.

## Installation

### Swift Package Manager

Add the `AndroidHardware` module as a conditional dependency for any targets that need it:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidHardware", package: "swift-android-native", condition: .when(platforms: [.android]))
])
```

## Usage

```swift
import AndroidHardware
import AndroidLooper

let manager = try SensorManager(package: "com.example.myapp")

// List all available sensors
let sensors = manager.sensors

// Get the default accelerometer
if let accelerometer = manager.defaultSensor(type: .accelerometer) {
    let looper = Looper.forThread()
    let queue = try manager.createEventQueue(looper: looper)
    try queue.enableSensor(accelerometer)

    var events = [SensorEvent](repeating: .init(), count: 8)
    let count = queue.getEvents(&events)
    // process events[0..<count]
}
```


# AndroidBootstrap

The [AndroidBootstrap] class is part of the top-level [AndroidNative] module, and provides
some conveniences for configuring Android to work with other Foundation types.

## Networking

Foundation's `URLSession` cannot load "https" URLs out of the box on Android because it
doesn't know where to look to find the local certificate authority files. In order to
set up `URLSession` properly, first call `AndroidBootstrap.setupCACerts()` one time
in order to initialize the certificate bundle.

For example:

```swift
import Foundation
#if os(Android)
import AndroidNative
import FoundationNetworking
#endif

#if os(Android)
try AndroidBootstrap.setupCACerts() // needed in order to use https
#endif
let url = URL(string: "https://httpbin.org/get?x=1")!
let (data, response) = try await URLSession.shared.data(from: url)
```

# License

Licensed under the Apache 2.0 license with a runtime library exception,
meaning you do not need to attribute the project in your application.
See the [LICENSE](LICENSE) file for details.
