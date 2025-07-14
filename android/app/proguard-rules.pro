# Flutter 관련 ProGuard 설정
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

# Google AdMob 관련 설정
-keep class com.google.android.gms.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.**

# Hive 관련 설정
-keep class * extends hive.HiveObject
-keep class * extends hive.HiveAdapter
-keep @hive.HiveType class *
-keep @hive.HiveField class *

# Riverpod 관련 설정
-keep class * extends riverpod.StateNotifier
-keep class * extends riverpod.Provider

# 일반적인 난독화 방지 설정
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
} 