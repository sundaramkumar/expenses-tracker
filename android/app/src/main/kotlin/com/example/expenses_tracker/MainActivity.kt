package com.example.expenses_tracker

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val INTENT_CHANNEL = "app.channel/intent"
    private val SMS_CHANNEL = "app.channel/sms"
    private val SMS_PERMISSION_REQUEST = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Intent channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getIntentExtras") {
                val extras = intent?.extras
                val map = HashMap<String, Any?>()
                if (extras != null) {
                    for (key in extras.keySet()) {
                        map[key] = extras.get(key)
                    }
                }
                result.success(map)
            } else {
                result.notImplemented()
            }
        }
        
        // SMS channel
        val smsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
        SmsReceiver.methodChannel = smsChannel
        
        smsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    requestSmsPermission()
                    result.success(null)
                }
                "checkPermission" -> {
                    val granted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(granted)
                }
                "readSms" -> {
                    val limit = call.argument<Int>("limit") ?: 100
                    if (checkSmsPermission()) {
                        val messages = readSmsMessages(limit)
                        result.success(messages)
                    } else {
                        result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun checkSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    private fun requestSmsPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS),
            SMS_PERMISSION_REQUEST
        )
    }
    
    private fun readSmsMessages(limit: Int): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("address", "body", "date")
        
        try {
            val cursor: Cursor? = contentResolver.query(
                uri,
                projection,
                null,
                null,
                "date DESC"
            )
            
            cursor?.use {
                val addressIndex = it.getColumnIndex("address")
                val bodyIndex = it.getColumnIndex("body")
                val dateIndex = it.getColumnIndex("date")
                
                var count = 0
                while (it.moveToNext() && count < limit) {
                    val sender = it.getString(addressIndex)
                    val body = it.getString(bodyIndex)
                    val timestamp = it.getLong(dateIndex)
                    
                    messages.add(mapOf(
                        "sender" to sender,
                        "body" to body,
                        "timestamp" to timestamp
                    ))
                    count++
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return messages
    }
}
