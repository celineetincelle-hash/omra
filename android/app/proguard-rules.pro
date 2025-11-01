# ===============================
# Flutter & Plugins
# ===============================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ===============================
# TensorFlow Lite GPU
# ===============================
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend { *; }

# ===============================
# Google ML Kit
# ===============================
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# ===============================
# Firebase
# ===============================
-keep class com.google.firebase.** { *; }

# ===============================
# Play Core / SplitInstall / Deferred Components
# ===============================
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# ===============================
# Health package
# ===============================
-keep class com.google.android.libraries.healthdata.** { *; }

# ===============================
# Prevent obfuscation of native methods
# ===============================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ===============================
# Keep custom Exception classes
# ===============================
-keep class * extends java.lang.Exception
