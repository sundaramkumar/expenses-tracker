package com.example.expenses_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import io.flutter.plugin.common.MethodChannel

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
                            // Send to Flutter
                            methodChannel?.invokeMethod("onSmsReceived", mapOf(
                                "sender" to sender,
                                "body" to messageBody,
                                "timestamp" to System.currentTimeMillis()
                            ))
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
}
