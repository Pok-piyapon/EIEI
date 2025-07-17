# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# LINE SDK ProGuard Rules
-keep class com.linecorp.linesdk.** { *; }
-dontwarn com.linecorp.linesdk.**

# Keep data binding classes
-keep class com.linecorp.linesdk.databinding.** { *; }
-keep class com.linecorp.linesdk.BR { *; }
-keep class com.linecorp.linesdk.BR$* { *; }

# Keep OpenChat related classes
-keep class com.linecorp.linesdk.openchat.** { *; }
-keep class com.linecorp.linesdk.openchat.ui.** { *; }

# Keep all LINE SDK model classes
-keep class com.linecorp.linesdk.api.** { *; }
-keep class com.linecorp.linesdk.auth.** { *; }
-keep class com.linecorp.linesdk.core.** { *; }
-keep class com.linecorp.linesdk.message.** { *; }
-keep class com.linecorp.linesdk.utils.** { *; }

# Keep Flutter LINE SDK plugin classes
-keep class com.linecorp.flutter_line_sdk.** { *; }

# Keep all VIEW_MODEL classes
-keep class **.*ViewModel { *; }
-keep class **.*ViewModelImpl { *; }

# Keep all data binding related classes
-keep class androidx.databinding.** { *; }
-dontwarn androidx.databinding.**

# Specific rules for the missing classes mentioned in the error
-keep class com.linecorp.linesdk.databinding.OpenChatInfoFragmentBindingImpl { *; }
-keep class com.linecorp.linesdk.openchat.ui.OpenChatInfoViewModel { *; }

# Keep all Fragment and ViewBinding classes
-keep class **.*Fragment { *; }
-keep class **.*FragmentBinding { *; }
-keep class **.*FragmentBindingImpl { *; }

# Additional LINE SDK specific rules
-keep class com.linecorp.linesdk.internal.** { *; }
-dontwarn com.linecorp.linesdk.internal.**

# General rules for maintaining functionality
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Retrofit and OkHttp (commonly used by LINE SDK)
-dontwarn retrofit2.**
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
