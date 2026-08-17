# ProGuard Rules for Unnati Jewellers (Flutter App)

This document details the ProGuard and R8 code shrinking/obfuscation rules configured for **Unnati Jewellers** Flutter Android application (`com.unnati.jewellers`).

---

## Overview

ProGuard/R8 shrinks, optimizes, and obfuscates your code to reduce app size and protect against reverse engineering. When building a release APK/AAB with code shrinking enabled (`isMinifyEnabled = true`), reflection-based libraries, native plugins, and JSON model classes require specific keep rules to prevent runtime crashes.

---

## 1. Complete ProGuard Configuration File (`android/app/proguard-rules.pro`)

Below is the complete set of rules generated specifically for this project based on `pubspec.yaml` dependencies and custom Dart/Java bindings.

```proguard
# ============================================================================
# General Android & General Optimization Rules
# ============================================================================
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Keep Enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve Native Method Names
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================================================
# Flutter Engine & Framework Rules
# ============================================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

# ============================================================================
# Firebase Core & Firebase Messaging (firebase_core, firebase_messaging)
# ============================================================================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# ============================================================================
# Networking - Dio, OkHttp & Socket.IO (dio, socket_io_client)
# ============================================================================
# Dio / OkHttp / Okio
-keep class dio.** { *; }
-dontwarn dio.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okio.**

# Socket.IO & Engine.IO
-keep class io.socket.** { *; }
-dontwarn io.socket.**
-keep class io.socket.engineio.client.** { *; }
-keep class io.socket.client.** { *; }
-keep class io.socket.emitter.** { *; }
-keep class io.socket.thread.** { *; }

# ============================================================================
# GetX & Local Storage (get, get_storage)
# ============================================================================
-keep class get.** { *; }
-dontwarn get.**
-keep class get_storage.** { *; }
-dontwarn get_storage.**

# ============================================================================
# Media & WebViews (webview_flutter, flutter_html, youtube_player_flutter)
# ============================================================================
# WebView Flutter & Android WebKit
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**
-keep class android.webkit.** { *; }
-dontwarn android.webkit.**

# YouTube Player Flutter
-keep class com.pierfrancescosoffritti.androidyoutubeplayer.** { *; }
-dontwarn com.pierfrancescosoffritti.androidyoutubeplayer.**

# ============================================================================
# Utilities & Plugins (image_picker, share_plus, path_provider, url_launcher, package_info_plus)
# ============================================================================
-keep class io.flutter.plugins.packageinfo.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.share.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }
-dontwarn io.flutter.plugins.**

# ============================================================================
# Typography & PDF (google_fonts, pdf)
# ============================================================================
-keep class com.google.fonts.** { *; }
-dontwarn com.google.fonts.**
-keep class net.sf.pdfbox.** { *; }
-dontwarn net.sf.pdfbox.**

# ============================================================================
# Application Package & Models
# ============================================================================
-keep class com.unnati.jewellers.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
```

---

## 2. Integration into `android/app/build.gradle.kts`

To enable ProGuard / R8 minification for release builds, update the `buildTypes` block in `android/app/build.gradle.kts`:

```kotlin
android {
    ...
    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile?.exists() == true) {
                signingConfig = releaseConfig
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }

            // Enable code shrinking and obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## 3. How to Build Release APK / App Bundle

To test ProGuard rules locally on release build:

```bash
# Build Release APK
flutter build apk --release

# Build Release App Bundle (AAB) for Play Store
flutter build appbundle --release
```

---

## 4. Key Rules Breakdown by Dependency

| Dependency                                   | Purpose of ProGuard Rule                                                            |
|:---------------------------------------------|:------------------------------------------------------------------------------------|
| `flutter`                                    | Preserves Flutter engine classes and platform channels                              |
| `firebase_core` / `firebase_messaging`       | Keeps Google Play Services & FCM messaging callbacks                                |
| `dio` / `socket_io_client`                   | Prevents obfuscation of HTTP headers, OkHttp reflective calls, and socket listeners |
| `get` / `get_storage`                        | Preserves GetX state controllers and key-value storage serialization                |
| `webview_flutter` / `youtube_player_flutter` | Keeps JavaScript interfaces and WebView native bindings                             |
| `google_fonts`                               | Preserves font fetchers and dynamic asset loaders                                   |
| `pdf` / `share_plus` / `image_picker`        | Keeps native platform channels for file sharing, picking, and PDF rendering         |
