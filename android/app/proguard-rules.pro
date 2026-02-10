# Flutter ProGuard Rules

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive
-keep class com.hive.** { *; }
-dontwarn com.hive.**

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Lottie
-keep class com.airbnb.lottie.** { *; }

# General
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Prevent obscuring of StackTraces
-keepattributes SourceFile,LineNumberTable

# Play Core (Deferred Components)
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**
