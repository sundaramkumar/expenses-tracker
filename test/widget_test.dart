import 'package:expenses_tracker/main.dart';
import 'package:expenses_tracker/pages/categories_page.dart';
import 'package:expenses_tracker/pages/subcategories_page.dart';
import 'package:expenses_tracker/pages/userprofile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Dashboard'), findsOneWidget);
    // expect(find.text('1'), findsNothing);
    expect(find.text('Transactions'), findsOneWidget);
    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    expect(find.text('Add Transaction'), findsAtLeast(1));
    // expect(find.descendant(of: find.byType(MyWidget), matching: find.text('0')), findsOneWidget);
  });

  testWidgets('Presence of specific widgets in SettingsPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to SettingsPage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify the presence of ListTiles
    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Subcategories'), findsOneWidget);
  });

  testWidgets('Navigation to UserProfilePage', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to SettingsPage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Tap on User Profile ListTile
    await tester.tap(find.text('User Profile'));
    await tester.pumpAndSettle();

    // Verify navigation to UserProfilePage
    expect(find.byType(UserProfilePage), findsOneWidget);
  });

  testWidgets('Navigation to CategoriesPage', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to SettingsPage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Tap on Categories ListTile
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    // Verify navigation to CategoriesPage
    expect(find.byType(CategoriesPage), findsOneWidget);
  });

  testWidgets('Navigation to SubcategoriesPage', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to SettingsPage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Tap on Subcategories ListTile
    await tester.tap(find.text('Subcategories'));
    await tester.pumpAndSettle();

    // Verify navigation to SubcategoriesPage
    expect(find.byType(SubcategoriesPage), findsOneWidget);
  });
}
