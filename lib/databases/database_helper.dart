import 'package:expenses_tracker/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'category.dart';
import 'subcategory.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expensestracker.db');
    print(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE "transactions" (
        "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "userId"	INTEGER NOT NULL,
        "transactionDate"	datetime NOT NULL DEFAULT current_timestamp,
        "description"	TEXT,
        "categoryId"	INTEGER NOT NULL,
        "subCategoryId"	INTEGER NOT NULL,
        "debit"	NUMERIC DEFAULT 0.0,
        "credit"	NUMERIC DEFAULT 0.0,
        "transactionType"	TEXT DEFAULT 'Cash'
      )
    ''');

    await db.execute('''
      CREATE TABLE "category" (
        "categoryId"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "categoryName"	TEXT NOT NULL,
        "userId"	INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE "subcategory" (
        "subCategoryId"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "categoryId"	INTEGER NOT NULL,
        "subCategoryName"	TEXT NOT NULL,
        "userId"	INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE "profile" (
        "userId"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "userName"	TEXT NOT NULL,
        "userEmail"	TEXT NOT NULL,
        "mobile"	TEXT NOT NULL,
        "plan"	TEXT DEFAULT 'FREE',
        "planType"	TEXT DEFAULT 'DEFAULT'
      )
    ''');

    await db.execute('''
      INSERT INTO category (categoryId, categoryName, userId)
        VALUES
        (1, 'Business', 1),
        (2, 'Cash', 1),
        (3, 'Children', 1),
        (4, 'CC', 1),
        (5, 'Construction', 1),
        (6, 'Education', 1),
        (7, 'Entertainment', 1),
        (8, 'Food', 1),
        (9, 'Gadgets', 1),
        (10, 'Gifts', 1),
        (11, 'Health', 1),
        (12, 'HomeExp', 1),
        (13, 'Income', 1),
        (14, 'Insurance', 1),
        (15, 'Investment', 1),
        (16, 'Loan', 1),
        (17, 'Legal', 1),
        (18, 'Magazines', 1),
        (19, 'Medical', 1),
        (20, 'Misc', 1),
        (21, 'Personal', 1),
        (22, 'PersonalCare', 1),
        (23, 'Phone', 1),
        (24, 'Property', 1),
        (25, 'Savings', 1),
        (26, 'Service', 1),
        (27, 'Specials', 1),
        (28, 'Tax', 1),
        (29, 'Travel', 1),
        (30, 'Vacation', 1),
        (31, 'Vehicle', 1)
    ''');
    await db.execute('''
     INSERT INTO subcategory (categoryId, subCategoryName, userId)
        VALUES
        (1, 'Flancing', 1),
        (1, 'Hosting', 1),
        (1, 'DomainReg', 1),
        (2, 'Borrow', 1),
        (2, 'CashAc', 1),
        (2, 'Lend', 1),
        (2, 'Return', 1),
        (3, 'Excursion', 1),
        (3, 'Hobbies', 1),
        (3, 'PocketMoney', 1),
        (3, 'SchoolSupplies', 1),
        (3, 'Shoes', 1),
        (3, 'SportAccessories', 1),
        (3, 'Stationary', 1),
        (3, 'Toys', 1),
        (4, 'Amex', 1),
        (4, 'HDFC', 1),
        (4, 'ICICI', 1),
        (4, 'SBI', 1),
        (5, 'Bank Fee', 1),
        (5, 'Bribe', 1),
        (5, 'Construction', 1),
        (5, 'Documentation', 1),
        (5, 'EB', 1),
        (5, 'Legal', 1),
        (5, 'Misc', 1),
        (5, 'Plan', 1),
        (5, 'RegOfc Fee', 1),
        (5, 'Regn Fee', 1),
        (5, 'Stamp Fee', 1),
        (5, 'Stationary', 1),
        (5, 'Xerox', 1),
        (6, 'ApplnFee', 1),
        (6, 'Books', 1),
        (6, 'Certification', 1),
        (6, 'CourseFee', 1),
        (6, 'Drawing', 1),
        (6, 'ExamFee', 1),
        (6, 'Guitar', 1),
        (6, 'Hindi', 1),
        (6, 'Hobbies', 1),
        (6, 'Karate', 1),
        (6, 'NoteBooksFee', 1),
        (6, 'SchoolBag', 1),
        (6, 'SchoolFee', 1),
        (6, 'Shoes', 1),
        (6, 'Stationary', 1),
        (6, 'Subscriptions', 1),
        (6, 'Training', 1),
        (6, 'Tuition', 1),
        (6, 'Uniform', 1),
        (7, 'Airtel DTH', 1),
        (7, 'Cable', 1),
        (7, 'CD/DVDs', 1),
        (7, 'Concert', 1),
        (7, 'Games', 1),
        (7, 'Movie', 1),
        (7, 'Subscription', 1),
        (8, 'Beverages', 1),
        (8, 'BreakFast', 1),
        (8, 'Dinner', 1),
        (8, 'Eatout', 1),
        (8, 'Food', 1),
        (8, 'Fruits', 1),
        (8, 'Lunch', 1),
        (8, 'Snacks', 1),
        (8, 'Water', 1),
        (9, 'Accessories', 1),
        (9, 'Camera', 1),
        (9, 'Computer', 1),
        (9, 'Gadgets', 1),
        (9, 'Laptop', 1),
        (9, 'Mobiles', 1),
        (9, 'Software', 1),
        (9, 'Spares', 1),
        (9, 'Svc Charges', 1),
        (9, 'Stationary', 1),
        (9, 'Watches', 1),
        (10, 'Annadhanam', 1),
        (10, 'Chittappa', 1),
        (10, 'Deekshidar', 1),
        (10, 'Charity', 1),
        (10, 'Gifts', 1),
        (10, 'Koil', 1),
        (10, 'Tips', 1),
        (10, 'TownMiss', 1),
        (11, 'Accessories', 1),
        (11, 'Gym', 1),
        (12, 'Eb', 1),
        (12, 'Flower', 1),
        (12, 'FoodItems', 1),
        (12, 'Fruits', 1),
        (12, 'Gas', 1),
        (12, 'Grocery', 1),
        (12, 'Household', 1),
        (12, 'Maintenance', 1),
        (12, 'Milk', 1),
        (12, 'Monthly Exp', 1),
        (12, 'Ration', 1),
        (12, 'Rent', 1),
        (12, 'Rice', 1),
        (12, 'Salary', 1),
        (12, 'Veg', 1),
        (12, 'VVR-Eb', 1),
        (12, 'Water', 1),
        (13, 'Axis Ac', 1),
        (13, 'Bank Incentive', 1),
        (13, 'Bonus', 1),
        (13, 'Borrow', 1),
        (13, 'Cash Ac', 1),
        (13, 'Chit Closure', 1),
        (13, 'Dividend', 1),
        (13, 'DomainReg', 1),
        (13, 'FDClosure', 1),
        (13, 'Freelancing', 1),
        (13, 'FuelSurcharge', 1),
        (13, 'GasSubsidary', 1),
        (13, 'Gifts', 1),
        (13, 'Homeloan', 1),
        (13, 'Hosting', 1),
        (13, 'ICICIAc', 1),
        (13, 'IndusAc', 1),
        (13, 'IncomeTaxReturns', 1),
        (13, 'Interest', 1),
        (13, 'LIC-SuvivalBenefit', 1),
        (13, 'MFRedemtion', 1),
        (13, 'PFClosure', 1),
        (13, 'PolicyClosure', 1),
        (13, 'PropertySale', 1),
        (13, 'RDClosure', 1),
        (13, 'Reinbursements', 1),
        (13, 'RentVVR', 1),
        (13, 'Salary', 1),
        (13, 'Shares Sold', 1),
        (13, 'TicketCancellation', 1),
        (13, 'Tuition', 1),
        (14, 'BikeInsurance', 1),
        (14, 'CarInsurance', 1),
        (14, 'LIC', 1),
        (14, 'MedIns', 1),
        (15, 'Diamond', 1),
        (15, 'Equity', 1),
        (15, 'Gold', 1),
        (15, 'Land', 1),
        (15, 'MF', 1),
        (15, 'NPS', 1),
        (15, 'PF', 1),
        (15, 'Platinum', 1),
        (15, 'PPF', 1),
        (15, 'Silver', 1),
        (15, 'ULIP', 1),
        (16, 'Car Loan', 1),
        (16, 'CC Loan', 1),
        (16, 'Dad', 1),
        (16, 'HandLoan', 1),
        (16, 'HomeLoan', 1),
        (16, 'HouseholdLoan', 1),
        (16, 'Interest', 1),
        (16, 'Jewel Loan', 1),
        (17, 'Auditor Fee', 1),
        (17, 'Broker Fee', 1),
        (17, 'Regn Fee', 1),
        (17, 'Patta', 1),
        (17, 'Stamp Fee', 1),
        (18, 'Books', 1),
        (18, 'eSubscription', 1),
        (18, 'NewsPaper', 1),
        (19, 'ClinicalTest', 1),
        (19, 'Doctor', 1),
        (19, 'Fund', 1),
        (19, 'Glasses_Lens', 1),
        (19, 'HospitalCharges', 1),
        (19, 'Medicines', 1),
        (19, 'Specs', 1),
        (20, 'Bank Charges', 1),
        (20, 'Courier', 1),
        (20, 'LockerRent', 1),
        (20, 'Misc', 1),
        (20, 'Parking', 1),
        (20, 'Postage', 1),
        (20, 'StkEx Charges', 1),
        (20, 'Xerox', 1),
        (21, 'Self', 1),
        (22, 'Accessories', 1),
        (22, 'Clothes', 1),
        (22, 'Cosmetics', 1),
        (22, 'Dress Stitching', 1),
        (22, 'DryClean', 1),
        (22, 'Haircut', 1),
        (22, 'Ornaments', 1),
        (22, 'Parlour', 1),
        (23, 'BBand', 1),
        (23, 'Airtel Familyplan', 1),
        (23, 'Mobile', 1),
        (23, 'Jio', 1),
        (23, 'Landline-Airtel', 1),
        (23, 'Mobile', 1),
        (23, 'Vodafone', 1),
        (23, 'VTSMobile', 1),
        (23, 'VVR-Landline', 1),
        (24, 'Accessories', 1),
        (24, 'Construction', 1),
        (24, 'Fixtures', 1),
        (24, 'Garden', 1),
        (24, 'Painting', 1),
        (24, 'Tax', 1),
        (24, 'Wages', 1),
        (25, 'AxisAc', 1),
        (25, 'Chit', 1),
        (25, 'Emergency', 1),
        (25, 'FD', 1),
        (25, 'GoldScheme', 1),
        (25, 'Jewel', 1),
        (25, 'RD', 1),
        (25, 'SavingsAc', 1),
        (26, 'AMC', 1),
        (26, 'SvcCharges', 1),
        (27, 'Apps', 1),
        (27, 'Function', 1),
        (27, 'gaana', 1),
        (27, 'Membership', 1),
        (27, 'Passport', 1),
        (27, 'StockSubscription', 1),
        (27, 'Youtube', 1),
        (27, 'Zomato', 1),
        (28, 'Prof Tax', 1),
        (28, 'SelfTax', 1),
        (29, 'Auto', 1),
        (29, 'Bus', 1),
        (29, 'Cab', 1),
        (29, 'Driver', 1),
        (29, 'Flight', 1),
        (29, 'Hotel', 1),
        (29, 'OlaSelect', 1),
        (29, 'Parking', 1),
        (29, 'PlatformTkt', 1),
        (29, 'SightSeeing', 1),
        (29, 'Toll', 1),
        (29, 'Train', 1),
        (30, 'Activities', 1),
        (30, 'Food', 1),
        (30, 'Lodging', 1),
        (30, 'Misc', 1),
        (30, 'Sight Seeing', 1),
        (30, 'Tips', 1),
        (30, 'Travel', 1),
        (31, 'Bike', 1),
        (31, 'Extended Warranty', 1),
        (31, 'Car', 1),
        (31, 'Cleaning', 1),
        (31, 'Driver', 1),
        (31, 'Insurance', 1),
        (31, 'Nitrogen', 1),
        (31, 'Parking', 1),
        (31, 'Petrol', 1),
        (31, 'Service/Repairs', 1),
        (31, 'Spares', 1)

    ''');
  }

  Future<int> signUp(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> loginUser(String username, String password) async {
    Database db = await database;

    List<Map> results = await db.query(
      'users',
      columns: ['id', 'username', 'password'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (results.length > 0) {
      return User.fromMap(Map<String, dynamic>.from(results.first));
    } else {
      return null;
    }
  }

  Future<int> insertExpense(Map<String, dynamic> expense) async {
    Database db = await database;
    return await db.insert('transactions', expense);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    Database db = await database;
    // return await db.query('transactions');
    return await db.rawQuery('''
    SELECT
      t.id,
      t.transactionDate,
      t.description,
      t.debit,
      t.credit,
      t.transactionType,
      c.categoryName,
      s.subCategoryName,
      c.categoryId,
      s.subCategoryId
    FROM
      transactions t
    JOIN
      category c ON t.categoryId = c.categoryId
    JOIN
      subcategory s ON t.subCategoryId = s.subCategoryId
    ORDER BY
      t.transactionDate DESC
  ''');
  }

  Future<List<Map<String, dynamic>>> getExpensesByDateRange(
      DateTime startDate, DateTime endDate) async {
    Database db = await database;
    return await db.query(
      'transactions',
      orderBy: 'transactionDate DESC',
      where: 'transactionDate >= ? AND transactionDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getExpensesForCurrentMonth() async {
    Database db = await database;
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return await db.query(
      'transactions',
      where: 'transactionDate >= ? AND transactionDate <= ?',
      whereArgs: [
        firstDayOfMonth.toIso8601String(),
        lastDayOfMonth.toIso8601String()
      ],
    );
  }

  Future<int> updateExpense(Map<String, dynamic> expense) async {
    Database db = await database;
    int id = expense['id'];
    return await db
        .update('transactions', expense, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    Database db = await database;
    return await db.query('category');
  }

  Future<List<Map<String, dynamic>>> getSubcategories(int categoryId) async {
    Database db = await database;
    return await db
        .query('subcategory', where: 'categoryId = ?', whereArgs: [categoryId]);
  }

  Future<List<Category>> getCategoriesList() async {
    Database db = await database;
    var categories =
        await db.rawQuery('SELECT * FROM category ORDER BY categoryName ASC');
    List<Category> categoryList = categories.isNotEmpty
        ? categories.map((c) => Category.fromMap(c)).toList()
        : [];
    categoryList.sort((a, b) => a.categoryName.compareTo(b.categoryName));

    return categoryList;
  }

  Future<int> addCategory(String categoryName) async {
    Database db = await database;
    int userId = 1;
    return await db.rawInsert(
        'INSERT INTO category'
        '(categoryName, userId) '
        'VALUES(?, ?)',
        [categoryName, userId]);
  }

  Future<int> updateCategory(int categoryId, String categoryName) async {
    Database db = await database;

    return await db.rawInsert("UPDATE category SET categoryName='$categoryName'"
        " WHERE categoryId=+$categoryId");
  }

  /// Delete a category and all its transactions and subcategories
  ///
  /// This function first deletes all transactions and subcategories
  /// associated with the category, then deletes the category itself.
  ///
  /// Returns the number of rows affected in the database
  Future<int> deleteCategory(int categoryId) async {
    Database db = await database;

    /// delete all transactions with the categoryId
    await db.delete('transactions',
        where: 'categoryId = ?', whereArgs: [categoryId]);

    /// delete all subcategories with the categoryId
    await db.delete('subcategory',
        where: 'categoryId = ?', whereArgs: [categoryId]);

    /// delete the category row from category table
    return await db
        .delete('category', where: 'categoryId = ?', whereArgs: [categoryId]);
  }

  /// Get all subcategories from the database
  ///
  /// Returns a list of Subcategory objects, or an empty list if the database
  /// is empty.
  Future<List<Subcategory>> getSubcategoriesList() async {
    Database db = await database;
    var subcategories = await db.query('subcategory');
    List<Subcategory> subcategoryList = subcategories.isNotEmpty
        ? subcategories.map((s) => Subcategory.fromMap(s)).toList()
        : [];
    return subcategoryList;
  }

  Future<int> addSubCategory(int categoryId, String subCategoryName) async {
    Database db = await database;
    int userId = 1;
    return await db.rawInsert(
        'INSERT INTO subcategory'
        '(categoryId, subCategoryName, userId) '
        'VALUES(?,?, ?)',
        [categoryId, subCategoryName, userId]);
  }

  Future<int> updateSubCategory(
      int subCategoryId, String subCategoryName) async {
    Database db = await database;

    return await db
        .rawUpdate("UPDATE subcategory SET subCategoryName='$subCategoryName'"
            " WHERE subCategoryId=+$subCategoryId");
  }

  Future<int> deleteSubCategory(int subCategoryId) async {
    Database db = await database;

    /// delete all transactions with the categoryId
    await db.delete('transactions',
        where: 'subCategoryId = ?', whereArgs: [subCategoryId]);

    /// delete all subcategories with the subCategoryId
    return await db.delete('subcategory',
        where: 'subCategoryId = ?', whereArgs: [subCategoryId]);
  }

  /// Returns the number of rows in the given table.
  ///
  /// The table name should be a valid table name in the database.
  /// The function returns the number of rows in the table.
  ///
  /// Example:
  ///
  ///
  Future<int> getRowsCount(String table) async {
    //database connection
    Database db = await database;
    var x = await db.rawQuery('SELECT COUNT (*) from $table');
    int count = Sqflite.firstIntValue(x) as int;
    return count;
  }

  /// Save the user profile to the database.
  ///
  /// Creates a new profile row in the database with the given parameters.
  /// The userId is hardcoded to 1 because there is only one user.
  Future<void> saveProfile(
      String userName, String userEmail, String mobile) async {
    Database db = await database;
    int userId = 1;
    await db.rawInsert(
        'INSERT INTO profile'
        '(userId, userName, userEmail, mobile, plan, planType) '
        'VALUES(?,?, ?, ?, ?, ?)',
        [userId, userName, userEmail, mobile, 'FREE', 'DEFAULT']);
  }

  /// Update the user profile in the database.
  ///
  /// Updates the user's name, email and mobile number in the database.
  /// The userId is hardcoded to 1 because there is only one user.
  ///
  Future<void> updateProfile(
      String userName, String userEmail, String mobile) async {
    Database db = await database;
    await db.rawUpdate(
        "UPDATE profile SET userName='$userName', userEmail='$userEmail', mobile='$mobile'"
        " WHERE userId=1");
  }

  /// load profile from database
  ///
  /// returns a list of maps containing:
  ///   - userId
  ///   - userName
  ///   - userEmail
  ///   - mobile
  ///   - plan
  ///   - planType
  Future<List<Map<String, dynamic>>> loadProfile() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT
      userId,userName,userEmail,mobile,plan,planType
      FROM
        profile
    ''');
  }

  Future<void> close() async {
    Database db = await database;
    await db.close();
  }
}
