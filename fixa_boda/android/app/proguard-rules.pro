# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep R class
-keep class com.example.fixa_boda.R { *; }
-keep class com.example.fixa_boda.R$* { *; }

# Suppress warnings for Flutter
-dontwarn io.flutter.**
