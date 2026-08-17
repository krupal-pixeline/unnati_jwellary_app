# ============================================================================
# ProGuard & R8 Optimization Rules for Unnati Jewellers
# Package: com.unnati.jewellers
# ============================================================================

# General Android & Reflection Attributes
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
# Firebase Core & Firebase Messaging
# ============================================================================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# ============================================================================
# Networking - Dio, OkHttp & Socket.IO
# ============================================================================
-keep class dio.** { *; }
-dontwarn dio.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okio.**

-keep class io.socket.** { *; }
-dontwarn io.socket.**
-keep class io.socket.engineio.client.** { *; }
-keep class io.socket.client.** { *; }
-keep class io.socket.emitter.** { *; }
-keep class io.socket.thread.** { *; }

# ============================================================================
# GetX & Local Storage
# ============================================================================
-keep class get.** { *; }
-dontwarn get.**
-keep class get_storage.** { *; }
-dontwarn get_storage.**

# ============================================================================
# Media & WebViews
# ============================================================================
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**
-keep class android.webkit.** { *; }
-dontwarn android.webkit.**

-keep class com.pierfrancescosoffritti.androidyoutubeplayer.** { *; }
-dontwarn com.pierfrancescosoffritti.androidyoutubeplayer.**

# ============================================================================
# Utilities & Flutter Community Plugins
# ============================================================================
-keep class io.flutter.plugins.packageinfo.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.share.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }
-dontwarn io.flutter.plugins.**

# ============================================================================
# Typography & PDF Generation
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
