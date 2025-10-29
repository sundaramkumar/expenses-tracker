import 'package:flutter/services.dart';
import '../utils/sms_parser.dart';
import '../databases/database_helper.dart';
import 'notification_service.dart';

class SmsService {
  static const platform = MethodChannel('app.channel/sms');
  static final SmsService _instance = SmsService._internal();
  
  factory SmsService() => _instance;
  
  SmsService._internal();

  Function(TransactionData)? onTransactionDetected;

  void initialize() {
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'onSmsReceived') {
      final data = Map<String, dynamic>.from(call.arguments);
      final sender = data['sender'] as String;
      final body = data['body'] as String;
      final timestamp = data['timestamp'] as int;

      print('SMS received from: $sender');
      print('Body: $body');

      // Parse the SMS
      final transaction = SmsParser.parse(body, timestamp);
      if (transaction != null) {
        print('Transaction detected: ${transaction.toMap()}');
        
        // Show notification instead of dialog
        await NotificationService().showTransactionNotification(transaction);
        
        // Also notify listeners if app is open
        if (onTransactionDetected != null) {
          onTransactionDetected!(transaction);
        }
      }
    }
  }

  Future<bool> checkPermission() async {
    try {
      final result = await platform.invokeMethod('checkPermission');
      return result as bool;
    } catch (e) {
      print('Error checking SMS permission: $e');
      return false;
    }
  }

  Future<void> requestPermission() async {
    try {
      await platform.invokeMethod('requestPermission');
    } catch (e) {
      print('Error requesting SMS permission: $e');
    }
  }

  Future<List<TransactionData>> scanHistoricalSms({int limit = 100}) async {
    try {
      final result = await platform.invokeMethod('readSms', {'limit': limit});
      final messages = List<Map<dynamic, dynamic>>.from(result);
      
      final transactions = <TransactionData>[];
      for (final msg in messages) {
        final body = msg['body'] as String;
        final timestamp = msg['timestamp'] as int;
        
        final transaction = SmsParser.parse(body, timestamp);
        if (transaction != null) {
          transactions.add(transaction);
        }
      }
      
      return transactions;
    } catch (e) {
      print('Error scanning historical SMS: $e');
      return [];
    }
  }

  Future<void> saveTransaction(TransactionData transaction, int categoryId, int subcategoryId) async {
    final dbHelper = DatabaseHelper();
    
    final data = {
      'userId': 1,
      'transactionDate': transaction.date.toIso8601String().split('T')[0],
      'description': transaction.merchant ?? (transaction.type == 'Income' ? 'Income' : 'Expense'),
      'debit': transaction.type == 'Expense' ? transaction.amount : 0.0,
      'credit': transaction.type == 'Income' ? transaction.amount : 0.0,
      'transactionType': 'UPI',
      'categoryId': categoryId,
      'subCategoryId': subcategoryId,
    };

    await dbHelper.insertExpense(data);
  }
}
