# TensorFlow Lite ProGuard rules
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Ignore missing optional dependencies (like GPU delegates if not used)
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.lite.support.**
