# Règles ProGuard pour CropGuardian

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Supabase
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Règles générales
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Désactiver les optimisations agressives
-dontoptimize
-dontobfuscate
