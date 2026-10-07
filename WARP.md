# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common commands

- Install dependencies
  ```sh path=null start=null
  flutter pub get
  ```
- Run the app (pick a connected device/emulator)
  ```sh path=null start=null
  flutter run
  ```
- Build release artifacts
  - Android APK
    ```sh path=null start=null
    flutter build apk --release
    ```
  - iOS (from macOS with Xcode configured)
    ```sh path=null start=null
    flutter build ios --release
    ```
- Lint/static analysis (configured via analysis_options.yaml using flutter_lints)
  ```sh path=null start=null
  flutter analyze
  ```
- Run tests (all)
  ```sh path=null start=null
  flutter test
  ```
- Run a single test file
  ```sh path=null start=null
  flutter test test/widget_test.dart
  ```

## Project architecture (high level)

- App entry and theming
  - `lib/main.dart` sets up `MaterialApp` and routes the initial UI to `HomePage`, disabling the debug banner and using a simple blue theme.

- Navigation shell
  - `lib/pages/home_page.dart` provides a `StatefulWidget` shell with a `BottomNavigationBar` controlling five primary sections: Dashboard, Reports, Add Transaction, Transactions, and Settings.
  - Navigation between sections replaces the entire `HomePage` via `Navigator.pushReplacement`, passing the selected child `Widget` and index.

- Persistence layer (SQLite via sqflite)
  - `lib/databases/database_helper.dart` is a singleton responsible for:
    - Opening a `sqflite` DB at `spendIt.db` and creating tables: `transactions`, `category`, `subcategory`, `profile`.
    - Seeding default `category` and `subcategory` data on first create.
    - CRUD and query helpers, including joins for rendering transactions with category/subcategory names and date-range utilities for dashboard/reports.
  - Simple data classes:
    - `lib/databases/category.dart` and `lib/databases/subcategory.dart` provide lightweight models with `fromMap`/`toMap`.

- Domain model(s)
  - `lib/models/expense.dart` defines an `Expense` model used sparingly; most pages work with raw `Map<String, dynamic>` from `DatabaseHelper`.

- Feature pages
  - Dashboard: `lib/pages/dashboard_page.dart` aggregates monthly income/expense totals and renders a ring chart (`pie_chart` package) and tabular summaries.
  - Reports: `lib/pages/reports_page.dart` lets users select date ranges and filter Income/Expenses; computes per-day aggregates and plots a line chart using `fl_chart`.
  - Transactions: `lib/pages/transactions_page.dart` lists joined transaction rows with edit/delete via `flutter_slidable`; refresh supported with `liquid_pull_to_refresh`.
  - Add/Edit Transaction: `lib/pages/expense_page.dart` handles the form for creating/updating a transaction, including category/subcategory lookups and validation.
  - Settings: `lib/pages/settings_page.dart` links to user profile, category and subcategory management pages.
  - Categories/Subcategories: `lib/pages/categories_page.dart`, `lib/pages/subcategories_page.dart` provide CRUD UIs backed by `DatabaseHelper` and the simple data classes above.
  - User Profile: `lib/pages/userprofile_page.dart` persists a single-profile row to the `profile` table and contains stubbed image/permission handling.

- Utilities and assets
  - `lib/utils/string_extension.dart` supplies a simple `String.capitalize()` extension; `lib/utils/task_button.dart` provides a small reusable button.
  - `pubspec.yaml` registers assets under `assets/images/` and `assets/icons/` used across pages (e.g., income/expense icons, profile placeholder).

## Notes specific to this repo

- Lints: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`. Use `flutter analyze` to surface issues; there are no custom disabled/enabled rules.
- Platforms: Source includes Android (`android/`), iOS (`ios/`), macOS (`macos/`), and Web (`web/manifest.json`). Build/run only the platforms supported by your environment.
- Database schema coupling: UI pages expect columns and join shapes from `DatabaseHelper` methods. When altering schema, update the join queries and dependent UI tables together.
- Test suite: `test/widget_test.dart` is present; extend with widget and database interaction tests as needed. Use file-level runs for faster iteration.
