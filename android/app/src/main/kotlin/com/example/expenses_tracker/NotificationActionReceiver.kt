package com.example.expenses_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import android.widget.Toast
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val transactionJson = intent.getStringExtra("transaction") ?: return

        Log.d("NotificationAction", "Received action: $action")

        when (action) {
            "ACTION_CONFIRM" -> {
                handleConfirm(context, transactionJson)
            }
            "ACTION_DISCARD" -> {
                handleDiscard(context)
            }
        }
    }

    fun handleConfirm(context: Context, transactionJson: String) {
        try {
            val json = JSONObject(transactionJson)
            val amount = json.getDouble("amount")
            val type = json.getString("type")
            val merchant = json.optString("merchant", type)
            val date = json.getString("date")
            val accountNumber = json.optString("accountNumber", null)
            val referenceNumber = json.optString("referenceNumber", null)

            // Open database
            val db = context.openOrCreateDatabase("expensestracker.db", Context.MODE_PRIVATE, null)

            // Get categories
            val categoryCursor = db.rawQuery("SELECT categoryId, categoryName FROM category", null)
            var categoryId = 1
            var suggestedCategory = getCategoryFromMerchant(merchant)
            
            while (categoryCursor.moveToNext()) {
                val catId = categoryCursor.getInt(0)
                val catName = categoryCursor.getString(1)
                if (catName == suggestedCategory) {
                    categoryId = catId
                    break
                }
            }
            categoryCursor.close()

            // Get first subcategory for this category
            val subCursor = db.rawQuery(
                "SELECT subCategoryId FROM subcategory WHERE categoryId = ? LIMIT 1",
                arrayOf(categoryId.toString())
            )
            var subcategoryId = categoryId
            if (subCursor.moveToFirst()) {
                subcategoryId = subCursor.getInt(0)
            }
            subCursor.close()

            // Insert transaction
            val values = ContentValues().apply {
                put("userId", 1)
                put("transactionDate", date)
                put("description", merchant)
                put("debit", if (type == "Expense") amount else 0.0)
                put("credit", if (type == "Income") amount else 0.0)
                put("transactionType", "UPI")
                put("categoryId", categoryId)
                put("subCategoryId", subcategoryId)
            }

            val result = db.insert("transactions", null, values)
            db.close()

            if (result != -1L) {
                Toast.makeText(context, "Transaction added: ₹$amount", Toast.LENGTH_SHORT).show()
                Log.d("NotificationAction", "Transaction saved successfully")
            } else {
                Toast.makeText(context, "Failed to add transaction", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Log.e("NotificationAction", "Error saving transaction", e)
            Toast.makeText(context, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun handleDiscard(context: Context) {
        Toast.makeText(context, "Transaction discarded", Toast.LENGTH_SHORT).show()
        Log.d("NotificationAction", "Transaction discarded")
    }

    private fun getCategoryFromMerchant(merchant: String): String {
        val merchantLower = merchant.lowercase()
        
        return when {
            Regex("zomato|swiggy|uber\\s*eats|food|restaurant|cafe|dominos|pizza|kfc|mcdonalds|burger|starbucks").containsMatchIn(merchantLower) -> "Food"
            Regex("amazon|flipkart|myntra|ajio|shoppers|reliance|dmart|big\\s*bazaar|mall").containsMatchIn(merchantLower) -> "Personal"
            Regex("uber|ola|rapido|metro|petrol|fuel|bpcl|iocl|hpcl").containsMatchIn(merchantLower) -> "Travel"
            Regex("netflix|prime|hotstar|spotify|youtube|bookmyshow|pvr|inox").containsMatchIn(merchantLower) -> "Entertainment"
            Regex("electricity|water|gas|phone|airtel|jio|vodafone|bsnl").containsMatchIn(merchantLower) -> "HomeExp"
            Regex("pharma|medical|hospital|doctor|clinic|apollo|fortis").containsMatchIn(merchantLower) -> "Medical"
            else -> "Misc"
        }
    }
}
