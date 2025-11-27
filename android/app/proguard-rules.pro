## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Keep SMS Receiver
-keep class com.example.expenses_tracker.SmsReceiver { *; }
-keep class com.example.expenses_tracker.NotificationActionReceiver { *; }
-keep class com.example.expenses_tracker.AddTransactionWidgetProvider { *; }

## Keep notification handling
-keep class com.dexterous.** { *; }
-keep class androidx.work.impl.** { *; }

## Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep JSON classes
-keep class org.json.** { *; }

## SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
