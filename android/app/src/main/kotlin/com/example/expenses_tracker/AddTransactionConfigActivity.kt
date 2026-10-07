package com.example.expenses_tracker

import android.app.Activity
import android.app.DatePickerDialog
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import android.view.View
import android.widget.*
import java.text.SimpleDateFormat
import java.util.*

class AddTransactionConfigActivity : Activity() {
    private lateinit var amountEt: EditText
    private lateinit var descriptionEt: EditText
    private lateinit var rbExpense: RadioButton
    private lateinit var rbIncome: RadioButton
    private lateinit var categorySpinner: Spinner
    private lateinit var subcategorySpinner: Spinner
    private lateinit var dateLayout: LinearLayout
    private lateinit var dateText: TextView
    private lateinit var submitBtn: Button
    private lateinit var cancelBtn: Button
    private lateinit var closeBtn: ImageButton

    private var selectedDate: Calendar = Calendar.getInstance()
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
    private val displayFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())

    private var categories = mutableListOf<Pair<Int, String>>()
    private var subcategories = mutableListOf<Pair<Int, String>>()
    private var allSubcategories = mutableListOf<Triple<Int, String, Int>>() // id, name, categoryId

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.add_transaction_config)

        initViews()
        setupListeners()
        loadCategories()
        updateDateDisplay()
    }

    private fun initViews() {
        amountEt = findViewById(R.id.et_amount)
        descriptionEt = findViewById(R.id.et_description)
        rbExpense = findViewById(R.id.rb_expense)
        rbIncome = findViewById(R.id.rb_income)
        categorySpinner = findViewById(R.id.spinner_category)
        subcategorySpinner = findViewById(R.id.spinner_subcategory)
        dateLayout = findViewById(R.id.layout_date)
        dateText = findViewById(R.id.tv_date)
        submitBtn = findViewById(R.id.btn_submit)
        cancelBtn = findViewById(R.id.btn_cancel)
        closeBtn = findViewById(R.id.btn_close)
    }

    private fun setupListeners() {
        submitBtn.setOnClickListener { saveTransaction() }
        cancelBtn.setOnClickListener { finish() }
        closeBtn.setOnClickListener { finish() }

        dateLayout.setOnClickListener { showDatePicker() }

        val rgType = findViewById<RadioGroup>(R.id.rg_type)
        rgType.setOnCheckedChangeListener { _, _ ->
            loadCategories()
        }

        categorySpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                if (categories.isNotEmpty()) {
                    loadSubcategories(categories[position].first)
                }
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }

    private fun showDatePicker() {
        DatePickerDialog(
            this,
            { _, year, month, day ->
                selectedDate.set(year, month, day)
                updateDateDisplay()
            },
            selectedDate.get(Calendar.YEAR),
            selectedDate.get(Calendar.MONTH),
            selectedDate.get(Calendar.DAY_OF_MONTH)
        ).show()
    }

    private fun updateDateDisplay() {
        dateText.text = displayFormat.format(selectedDate.time)
    }

    private fun loadCategories() {
        val db = openOrCreateDatabase("spendIt.db", MODE_PRIVATE, null)

        categories.clear()
        val cursor = db.rawQuery("SELECT categoryId, categoryName FROM category", null)

        while (cursor.moveToNext()) {
            val id = cursor.getInt(0)
            val name = cursor.getString(1)
            categories.add(Pair(id, name))
        }
        cursor.close()

        // Load all subcategories for filtering
        allSubcategories.clear()
        val subCursor = db.rawQuery("SELECT subCategoryId, subCategoryName, categoryId FROM subcategory", null)
        while (subCursor.moveToNext()) {
            allSubcategories.add(Triple(subCursor.getInt(0), subCursor.getString(1), subCursor.getInt(2)))
        }
        subCursor.close()
        db.close()

        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, categories.map { it.second })
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        categorySpinner.adapter = adapter

        if (categories.isNotEmpty()) {
            loadSubcategories(categories[0].first)
        }
    }

    private fun loadSubcategories(categoryId: Int) {
        subcategories.clear()
        subcategories.addAll(
            allSubcategories
                .filter { it.third == categoryId }
                .map { Pair(it.first, it.second) }
        )

        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, subcategories.map { it.second })
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        subcategorySpinner.adapter = adapter
    }

    private fun saveTransaction() {
        val amount = amountEt.text.toString().trim()
        val description = descriptionEt.text.toString().trim()

        if (amount.isEmpty()) {
            Toast.makeText(this, "Please enter amount", Toast.LENGTH_SHORT).show()
            return
        }

        if (categories.isEmpty()) {
            Toast.makeText(this, "No categories available", Toast.LENGTH_SHORT).show()
            return
        }

        val isIncome = rbIncome.isChecked
        val categoryPos = categorySpinner.selectedItemPosition
        val subcategoryPos = subcategorySpinner.selectedItemPosition

        val categoryId = categories[categoryPos].first
        val subcategoryId = if (subcategories.isNotEmpty()) subcategories[subcategoryPos].first else categoryId
        val date = dateFormat.format(selectedDate.time)
        val amountValue = amount.toDoubleOrNull()

        if (amountValue == null || amountValue <= 0) {
            Toast.makeText(this, "Please enter a valid amount", Toast.LENGTH_SHORT).show()
            return
        }

        try {
            val db = openOrCreateDatabase("spendIt.db", MODE_PRIVATE, null)
            val values = ContentValues().apply {
                put("userId", 1)
                put("transactionDate", date)
                put("description", description.ifEmpty { if (isIncome) "Income" else "Expense" })
                put("debit", if (isIncome) 0.0 else amountValue)
                put("credit", if (isIncome) amountValue else 0.0)
                put("transactionType", "Cash")
                put("categoryId", categoryId)
                put("subCategoryId", subcategoryId)
            }

            val result = db.insert("transactions", null, values)
            db.close()

            if (result != -1L) {
                Toast.makeText(this, "Transaction added successfully", Toast.LENGTH_SHORT).show()
                finish()
            } else {
                Toast.makeText(this, "Failed to add transaction", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Toast.makeText(this, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}
