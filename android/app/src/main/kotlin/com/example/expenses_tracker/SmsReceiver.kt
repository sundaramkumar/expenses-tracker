package com.example.expenses_tracker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.SmsMessage
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class SmsReceiver : BroadcastReceiver() {
    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
            if (bundle != null) {
                try {
                    val pdus = bundle.get("pdus") as Array<*>
                    for (pdu in pdus) {
                        val message = SmsMessage.createFromPdu(pdu as ByteArray)
                        val sender = message.displayOriginatingAddress
                        val messageBody = message.messageBody
                        
                        // Check if it's a bank SMS (contains common keywords)
                        if (isBankSms(sender, messageBody)) {
                            android.util.Log.d("SmsReceiver", "Bank SMS detected from: $sender")
                            
                            // Try to send to Flutter first
                            if (methodChannel != null) {
                                try {
                                    methodChannel?.invokeMethod("onSmsReceived", mapOf(
                                        "sender" to sender,
                                        "body" to messageBody,
                                        "timestamp" to System.currentTimeMillis()
                                    ))
                                    android.util.Log.d("SmsReceiver", "SMS sent to Flutter successfully")
                                } catch (e: Exception) {
                                    android.util.Log.e("SmsReceiver", "Error sending SMS to Flutter", e)
                                    // Fallback: show notification directly
                                    showNativeNotification(context, sender, messageBody)
                                }
                            } else {
                                android.util.Log.w("SmsReceiver", "MethodChannel is null, showing native notification")
                                // Flutter engine not running, show notification directly
                                showNativeNotification(context, sender, messageBody)
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
    
    private fun isBankSms(sender: String, body: String): Boolean {
        val bankKeywords = listOf(
            "debited", "credited", "withdrawn", "deposited",
            "paid", "received", "transaction", "transfer",
            "upi", "a/c", "account", "balance", "avl bal",
            "Rs", "INR", "₹"
        )
        
        val bankSenders = listOf(
            "SBIINB", "HDFCBK", "ICICIB", "AXISBK", "KOTAKB",
            "INDBNK", "PNBSMS", "BOISMS", "UNions", "CANBKS",
            "IDBIBK", "SCBANK", "CITIBK", "HSBCIN", "YESBNK",
            "FEDBK", "RBLBK", "BANDHN", "AUBANK", "PAYTM",
            "PHONEPE", "GOOGLEPAY", "AMAZONPAY", "BHIM"
        )
        
        // Check if sender matches bank pattern
        val senderUpper = sender.uppercase()
        val matchesSender = bankSenders.any { senderUpper.contains(it) }
        
        // Check if body contains bank keywords
        val bodyLower = body.lowercase()
        val matchesKeyword = bankKeywords.any { bodyLower.contains(it) }
        
        return matchesSender || matchesKeyword
    }
    
    private fun showNativeNotification(context: Context?, sender: String, body: String) {
        if (context == null) return
        
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "transaction_channel"
        
        // Create notification channel for Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Transaction Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Bank transaction notifications"
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
        
        // Create intent to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("openNotification", true)
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build notification
        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Bank Transaction Detected")
            .setContentText("Tap to view and save transaction")
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText(body.take(200)))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()
        
        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }
}
