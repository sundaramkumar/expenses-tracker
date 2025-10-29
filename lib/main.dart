import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/home_page.dart';
import 'package:expenses_tracker/pages/splash_screen.dart';
import 'package:expenses_tracker/theme/theme_controller.dart';
import 'package:expenses_tracker/services/sms_service.dart';
import 'package:expenses_tracker/services/notification_service.dart';
import 'package:expenses_tracker/widgets/transaction_confirmation_dialog.dart';
import 'package:expenses_tracker/utils/sms_parser.dart';
import 'package:expenses_tracker/databases/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SmsService _smsService = SmsService();
  final NotificationService _notificationService = NotificationService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    _smsService.initialize();
    _smsService.onTransactionDetected = _handleTransactionDetected;
    
    // Handle notification actions
    _notificationService.onConfirm = _handleConfirm;
    _notificationService.onEdit = _handleEdit;
    _notificationService.onDiscard = _handleDiscard;
  }

  Future<void> _handleConfirm(TransactionData transaction) async {
    // Auto-save with default category
    final dbHelper = DatabaseHelper();
    final categories = await dbHelper.getCategories();
    
    if (categories.isEmpty) return;
    
    final suggestedCategory = SmsParser.getCategoryFromMerchant(transaction.merchant);
    final category = categories.firstWhere(
      (c) => c['categoryName'] == suggestedCategory,
      orElse: () => categories.first,
    );
    
    final subcategories = await dbHelper.getSubcategories(category['categoryId']);
    if (subcategories.isEmpty) return;
    
    await _smsService.saveTransaction(
      transaction,
      category['categoryId'],
      subcategories.first['subCategoryId'],
    );
  }

  void _handleEdit(TransactionData transaction) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => TransactionConfirmationDialog(
          transaction: transaction,
        ),
      );
    }
  }

  void _handleDiscard(TransactionData transaction) {
    // Just dismiss - notification already cancelled
    print('Transaction discarded: ${transaction.amount}');
  }

  void _handleTransactionDetected(TransactionData transaction) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => TransactionConfirmationDialog(
          transaction: transaction,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0EA5A5); // Teal accent

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    final baseInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: lightColorScheme.outlineVariant),
    );

    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'SpendIt',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController.instance.mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            scaffoldBackgroundColor: const Color(0xFFF7F7FA),
            fontFamily: 'Roboto',
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: lightColorScheme.surface,
              foregroundColor: lightColorScheme.onSurface,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: lightColorScheme.onPrimary,
                backgroundColor: lightColorScheme.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(12),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: baseInputBorder,
              enabledBorder: baseInputBorder,
              focusedBorder: baseInputBorder.copyWith(
                borderSide:
                    BorderSide(color: lightColorScheme.primary, width: 2),
              ),
              labelStyle: TextStyle(color: lightColorScheme.onSurfaceVariant),
            ),
            chipTheme: ChipThemeData(
              selectedColor: lightColorScheme.primary.withValues(alpha: 0.12),
              side: BorderSide(color: lightColorScheme.outlineVariant),
              shape: StadiumBorder(
                  side: BorderSide(color: lightColorScheme.outlineVariant)),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: lightColorScheme.surface,
              selectedItemColor: lightColorScheme.primary,
              unselectedItemColor: lightColorScheme.onSurfaceVariant,
              elevation: 8,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            canvasColor: Colors.black,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: darkColorScheme.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF0D0D0D),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(12),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF111111),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: baseInputBorder,
              enabledBorder: baseInputBorder,
              focusedBorder: baseInputBorder.copyWith(
                borderSide:
                    BorderSide(color: darkColorScheme.primary, width: 2),
              ),
              labelStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFF121212),
              selectedColor: darkColorScheme.primary.withValues(alpha: 0.18),
              side: BorderSide(color: Colors.white10),
              shape: const StadiumBorder(),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              elevation: 8,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomePage(initialIndex: 0),
          },
        );
      },
    );
  }
}
