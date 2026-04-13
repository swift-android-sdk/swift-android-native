# SwiftAndroidNative

This package provides a Swift interface to various
Android [NDK APIs](https://developer.android.com/ndk/reference)
and utilities to integrate Swift Foundation with the Android environment.

## Requirements

- Swift 6
- [Swift Android Toolchain and SDK](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html)

## Installation

### Swift Package Manager

Add the package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/swift-android-sdk/swift-android-native.git", from: "1.5.0")
]
```

## Available Modules

The package is split into small, focused library products so you can pull in
only what you need. Each module is a thin, idiomatic Swift wrapper around the
corresponding Android NDK C API.

| Module | Purpose | Underlying Android API |
|---|---|---|
| [`AndroidNative`](#androidnative-and-androidbootstrap) | Umbrella module with Foundation bootstrap helpers | — |
| [`AndroidSystem`](#androidsystem) | Low-level file, socket, and errno primitives | [`<unistd.h>`, `<sys/*>`](https://developer.android.com/ndk/reference) |
| [`AndroidLogging`](#androidlogging) | `Logger` API compatible with Apple's `OSLog` | [`__android_log_write`](https://developer.android.com/ndk/reference/group/logging) |
| [`AndroidContext`](#androidcontext) | Wrapper for `android.content.Context` over raw JNI | [`android.content.Context`](https://developer.android.com/reference/android/content/Context) |
| [`AndroidFileManager`](#androidfilemanager) | APK assets, storage, and OBB expansion files | [`AAssetManager`](https://developer.android.com/ndk/reference/group/asset), [`AStorageManager`](https://developer.android.com/ndk/reference/group/storage) |
| [`AndroidLooper`](#androidlooper) | Thread event loops and `@MainActor`-style scheduling | [`ALooper`](https://developer.android.com/ndk/reference/group/looper) |
| [`AndroidChoreographer`](#androidchoreographer) | Frame-timing callbacks synced to the display vsync | [`AChoreographer`](https://developer.android.com/ndk/reference/group/choreographer) |
| [`AndroidManifest`](#androidmanifest) | Runtime permission queries | [`APermissionManager`](https://developer.android.com/ndk/reference/group/permission), [`Manifest.permission`](https://developer.android.com/reference/android/Manifest.permission) |
| [`AndroidInput`](#androidinput) | Key, motion, and game controller input events | [`AInputQueue`, `AInputEvent`](https://developer.android.com/ndk/reference/group/input) |
| [`AndroidHardware`](#androidhardware) | Hardware sensors (accelerometer, gyro, etc.) | [`ASensorManager`](https://developer.android.com/ndk/reference/group/sensor) |
| [`AndroidBinder`](#androidbinder) | Native binder IPC (API 29+) | [`AIBinder`](https://developer.android.com/ndk/reference/group/ndk-binder) |

All modules below are conditionally imported and should typically be added
to a target only for Android builds:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "AndroidLogging", package: "swift-android-native", condition: .when(platforms: [.android])),
    .product(name: "AndroidContext", package: "swift-android-native", condition: .when(platforms: [.android])),
    // …additional modules
])
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
for Darwin platforms. Messages are forwarded to the Android log buffer and
can be viewed with [logcat](https://developer.android.com/tools/logcat).

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
logger.error("Something went wrong: \(error)")
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
to bridge into the global application context. The application `Context` is
Android's primary entry point for resolving resources, package metadata,
file paths, system services, and much more — see the official
[Context documentation](https://developer.android.com/reference/android/content/Context)
for the full surface area.

## Usage

```swift
import AndroidContext

let context = try AndroidContext.application
let packageName = try context.getPackageName()
let filesDir = try context.getFilesDir()    // app's private files directory
let cacheDir = try context.getCacheDir()    // app's private cache directory
```

## Bootstrapping the Context

The recommended way to initialize `AndroidContext` is to call `setSharedContext(_:env:)`
as early as possible — before any code accesses `AndroidContext.application`. This avoids
the automatic JVM lookup and reflective factory call entirely, giving you full control over
how the context is provided.

### From `JNI_OnLoad`

If your Swift code is loaded as a shared library by Java (e.g. via `System.loadLibrary`),
implement the standard [`JNI_OnLoad`](https://docs.oracle.com/en/java/javase/21/docs/specs/jni/invocation.html#jni_onload)
entry point. The `JavaVM` pointer gives you a `JNIEnvironment`, and you can then look up
the application context:

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


# AndroidFileManager

This module wraps Android's asset and storage APIs, giving native Swift code
access to files packaged inside an APK, the app's private storage, and
[expansion (OBB) files](https://developer.android.com/google/play/expansion-files).
It is the idiomatic way to read bundled resources such as images, JSON data,
fonts, or HTML content from native Swift.

The main public types are:

- `AssetManager` — a wrapper around [`AAssetManager`](https://developer.android.com/ndk/reference/group/asset#aassetmanager).
- `Asset` — a handle to a single asset returned by `AAssetManager_open`.
- `AssetDirectory` — iterates asset file names under a directory.
- `Configuration` — wraps [`AConfiguration`](https://developer.android.com/ndk/reference/group/configuration), the device runtime configuration (locale, density, screen size, etc.).
- `StorageManager` / `ObbFile` / `ObbInfo` — wrap [`AStorageManager`](https://developer.android.com/ndk/reference/group/storage) for mounting and querying OBB expansion files.

## Usage

### Reading an APK asset

```swift
import AndroidFileManager
import AndroidContext

// Get the native AAssetManager* for the application.
let context = try AndroidContext.application
let assets = try context.getAssetManager()

// Open an asset packaged in the APK under `src/main/assets/`
let asset = try assets.open("config/settings.json", mode: .buffer)
defer { asset.close() }

let length = asset.length
if let bytes = asset.buffer {
    let data = Data(bytes: bytes, count: Int(length))
    // …decode data
}

// Iterate a directory of assets
let dir = try assets.openDirectory("images")
while let name = dir.nextFileName() {
    print("asset:", name)
}
```

### Mounting an OBB expansion file

```swift
import AndroidFileManager

let storage = StorageManager()
try storage.mountObb(filename: "/sdcard/Android/obb/com.example/main.1.com.example.obb",
                     key: nil) { state, path in
    // State callback — see AStorageManager mount states
}
```


# AndroidLooper

This module wraps the NDK [Looper](https://developer.android.com/ndk/reference/group/looper)
event loop, which is the foundation of Android's main thread and of any thread
that processes input, sensors, or asynchronous I/O. It also provides
`AndroidMainActor`, a Swift global actor backed by the Android main looper,
so you can write main-thread code using `async`/`await`.

The main public types are:

- `Looper` — a non-copyable handle to the thread-local `ALooper`.
- `AndroidMainActor` — a `@globalActor` that schedules work on the Android main thread.

## Usage

### Running work on the Android main thread

```swift
import AndroidLooper

// Call once, early in startup (e.g. from JNI_OnLoad), to bind the main looper.
AndroidMainActor.setupMainLooper()

@AndroidMainActor
func updateUI() {
    // Runs on the Android main thread, via ALooper_pollOnce.
}

Task { @AndroidMainActor in
    updateUI()
}
```

### Preparing a looper for a background thread

```swift
// Attach (or create) a looper for the current thread.
let looper = Looper.currentThread(options: [.allowNonCallbacks])

// Another thread can wake this looper out of a blocking poll:
looper.wake()
```


# AndroidChoreographer

This module wraps [`AChoreographer`](https://developer.android.com/ndk/reference/group/choreographer),
Android's display frame-timing coordinator. Use it to schedule callbacks that
fire in lockstep with the display vsync, which is the correct way to drive
animations, custom rendering, or game loops so that frames are presented
smoothly.

## Usage

```swift
import AndroidChoreographer
import AndroidLooper

// Call once on the main thread to bind the choreographer to the main looper.
AndroidChoreographer.setupMainChoreographer()

// Schedule a frame callback. The callback fires once per vsync.
let choreographer = AndroidChoreographer.current
choreographer.postFrameCallback { frameTimeNanos, userData in
    // Advance animation / render the next frame.
    // Re-post from inside the callback to run every frame.
}
```

See Android's [frame pacing guide](https://developer.android.com/games/sdk/frame-pacing)
for a discussion of why vsync-aligned callbacks matter for smooth rendering.


# AndroidManifest

This module provides access to Android's [runtime permission](https://developer.android.com/guide/topics/permissions/overview)
system. Permission identifiers mirror the constants defined on
[`android.Manifest.permission`](https://developer.android.com/reference/android/Manifest.permission)
and permission groups mirror [`android.Manifest.permission_group`](https://developer.android.com/reference/android/Manifest.permission_group).

Checks go through the NDK [`APermissionManager_checkPermission`](https://developer.android.com/ndk/reference/group/permission)
API, which underneath consults [`ContextCompat.checkSelfPermission`](https://developer.android.com/training/permissions/requesting#explain).

Declaring a permission in your `AndroidManifest.xml` and calling
`Permission.X.isGranted` only tells you whether the user has already granted
it — if it hasn't been granted, you still need to request it from Kotlin/Java
code via [`ActivityCompat.requestPermissions`](https://developer.android.com/training/permissions/requesting).

## Usage

```swift
import AndroidManifest

// Check whether the app has already been granted a permission.
if Permission.readExternalStorage.isGranted {
    // access storage
}

if Permission.accessFineLocation.isGranted {
    // read GPS
}

// Check with explicit PID/UID (requires Android 31+)
let status = try Permission.camera.check()
switch status {
case .granted: break
case .denied:  break
}
```


# AndroidInput

This module wraps the NDK [Input](https://developer.android.com/ndk/reference/group/input)
APIs, including input queues, key events, motion events, and game controller
state. It is most commonly used from native activities or game engines that
want to read touch, keyboard, and gamepad input directly instead of going
through a Java `View`.

The main public types are:

- `InputQueue` — a wrapper around [`AInputQueue`](https://developer.android.com/ndk/reference/group/input#ainputqueue).
- `InputEvent` — a wrapper around [`AInputEvent`](https://developer.android.com/ndk/reference/group/input#ainputevent), representing either a key or motion event.
- `GameController` — a helper for querying connected controllers (see the [game controller guide](https://developer.android.com/games/controllers/controller-input)).
- `Keycodes` — Swift constants mirroring `AKEYCODE_*` values.

## Usage

```swift
import AndroidInput
import AndroidLooper

// Attach an input queue (e.g. one obtained from ANativeActivityCallbacks) to
// the current thread's looper so that events wake us from polling.
let looper = Looper.currentThread(options: [])
inputQueue.attachLooper(looper, identifier: 1, callback: nil, data: nil)

var event: InputEvent?
if inputQueue.hasEvents() > 0 {
    inputQueue.getEvent(&event)
    if let event {
        // Dispatch to IME first, then handle:
        inputQueue.finishEvent(event, handled: true)
    }
}
```


# AndroidHardware

This module wraps the NDK [Sensor](https://developer.android.com/ndk/reference/group/sensor)
API, giving you native access to the device's hardware sensors: accelerometer,
gyroscope, magnetometer, light, proximity, pressure, step counter, and many
more. See the [sensor types reference](https://developer.android.com/reference/android/hardware/Sensor#sensor-types)
for the full list.

The main public types are:

- `SensorManager` — the factory for sensor discovery and event queues, wrapping [`ASensorManager`](https://developer.android.com/ndk/reference/group/sensor#asensormanager).
- `Sensor` — a handle to a single sensor with name, vendor, range, and resolution.
- `SensorEventQueue` — an event queue attached to a looper, wrapping [`ASensorEventQueue`](https://developer.android.com/ndk/reference/group/sensor#asensoreventqueue).
- `SensorType` — enum mirroring `ASENSOR_TYPE_*` values.
- `SensorEvent` — a value type carrying a reading (acceleration, rotation, etc.).

## Usage

```swift
import AndroidHardware
import AndroidLooper

let manager = try SensorManager(package: "com.example.myapp")

// List all available sensors
for sensor in manager.sensors {
    print(sensor.name, sensor.type)
}

// Read accelerometer samples on the current looper thread
if let accelerometer = manager.defaultSensor(type: .accelerometer) {
    let looper = Looper.currentThread(options: [])
    let queue = try manager.createEventQueue(looper: looper)
    try queue.enableSensor(accelerometer)

    var events = [SensorEvent](repeating: .init(), count: 8)
    let count = queue.getEvents(&events)
    for event in events[0..<count] {
        // event.acceleration.x / .y / .z
    }
}
```


# AndroidBinder

This module wraps Android's stable NDK [binder](https://developer.android.com/ndk/reference/group/ndk-binder)
IPC API (`AIBinder`, available from API level 29). Binder is the foundation of
all inter-process communication on Android — every `Service` bound with
`bindService`, every call to a system service, and every AIDL interface goes
through it. See the Android [Binder IPC documentation](https://source.android.com/docs/core/architecture/hidl/binder-ipc)
for a deeper dive into the protocol.

> **Note:** This module is only available when targeting Android API 29 or later.
> Set `ANDROID_SDK_VERSION=29` (or higher) when building the package.

The main public types are:

- `AndroidBinder` — a local or remote binder object, wrapping [`AIBinder`](https://developer.android.com/ndk/reference/group/ndk-binder#aibinder).
- `BinderClass` — defines an interface descriptor and `onCreate` / `onDestroy` / `onTransact` callbacks, wrapping [`AIBinder_Class`](https://developer.android.com/ndk/reference/group/ndk-binder#aibinder_class).
- `Parcel` — a non-copyable container for serializing and deserializing transaction arguments, wrapping [`AParcel`](https://developer.android.com/ndk/reference/group/ndk-binder#aparcel).
- `DeathRecipient` — a callback invoked when a remote binder dies, wrapping [`AIBinder_DeathRecipient`](https://developer.android.com/ndk/reference/group/ndk-binder#aibinder_deathrecipient).
- `Status` / `BinderException` — structured error reporting for failed transactions.

## Usage

### Implementing a local binder service

```swift
import AndroidBinder

let service = BinderClass(
    interfaceDescriptor: "com.example.IMyService",
    onCreate: { _ in /* return user data */ nil },
    onDestroy: { _ in },
    onTransact: { binder, code, input, output in
        // Decode arguments from `input`, write results to `output`.
        return .ok
    }
)

let binder = AndroidBinder(class: service)!
```

### Monitoring a remote binder for death

```swift
let recipient = DeathRecipient { /* remote process exited */ }
try remoteBinder.linkToDeath(recipient)
```

### Transferring a binder across a JNI boundary

A `jobject` obtained from Java (e.g. a `Service.onBind` result) can be
converted into an `AndroidBinder` using the NDK `AIBinder_fromJavaBinder`
helper exposed by this module, and vice versa, so you can share a single
binder instance between Java/Kotlin and Swift code.


# AndroidSystem

`AndroidSystem` is a low-level building block that most applications will not
use directly. It provides platform-independent wrappers for
[`<unistd.h>`](https://developer.android.com/ndk/reference/group/libc), file
descriptors, socket descriptors, file permissions, and `errno` constants,
borrowed from and API-compatible with Apple's
[swift-system](https://github.com/apple/swift-system) package. Higher-level
modules (`AndroidLooper`, `AndroidFileManager`, `AndroidBinder`) build on top
of it.


# AndroidNative and AndroidBootstrap

The top-level `AndroidNative` module re-exports the most commonly used
submodules and adds `AndroidBootstrap`, a small collection of helpers for
configuring Foundation and other Swift libraries to work correctly on Android.

## Networking

Foundation's `URLSession` cannot load "https" URLs out of the box on Android because it
doesn't know where to look to find the local certificate authority files. Android stores
CA certificates under [`/system/etc/security/cacerts`](https://source.android.com/docs/security/features/selinux/implement)
and (on modern devices) under `/apex/com.android.conscrypt/cacerts`.

In order to set up `URLSession` properly, first call `AndroidBootstrap.setupCACerts()`
one time in order to build a PEM bundle from those directories and point
libcurl-backed networking at it.

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
