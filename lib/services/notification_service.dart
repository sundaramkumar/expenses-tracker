import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../utils/sms_parser.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  Function(TransactionData)? onConfirm;
  Function(TransactionData)? onEdit;
  Function(TransactionData)? onDiscard;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationResponse,
    );

    // Request notification permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification action
    _handleAction(response);
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _handleAction(response);
  }

  static void _handleAction(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final data = jsonDecode(response.payload!);
      final transaction = TransactionData(
        amount: data['amount'],
        type: data['type'],
        merchant: data['merchant'],
        date: DateTime.parse(data['date']),
        accountNumber: data['accountNumber'],
        referenceNumber: data['referenceNumber'],
        rawMessage: data['rawMessage'],
      );

      final instance = NotificationService();
      
      switch (response.actionId) {
        case 'confirm':
          instance.onConfirm?.call(transaction);
          break;
        case 'edit':
          instance.onEdit?.call(transaction);
          break;
        case 'discard':
          instance.onDiscard?.call(transaction);
          break;
      }
    } catch (e) {
      print('Error handling notification action: $e');
    }
  }

  Future<void> showTransactionNotification(TransactionData transaction) async {
    final payload = jsonEncode({
      'amount': transaction.amount,
      'type': transaction.type,
      'merchant': transaction.merchant,
      'date': transaction.date.toIso8601String(),
      'accountNumber': transaction.accountNumber,
      'referenceNumber': transaction.referenceNumber,
      'rawMessage': transaction.rawMessage,
    });

    final androidDetails = AndroidNotificationDetails(
      'transaction_channel',
      'Transaction Notifications',
      channelDescription: 'Notifications for detected bank transactions',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        _buildNotificationBody(transaction),
        htmlFormatBigText: true,
        contentTitle: _buildNotificationTitle(transaction),
        htmlFormatContentTitle: true,
        summaryText: transaction.type == 'Income' ? 'Money received' : 'Money spent',
      ),
      icon: '@mipmap/ic_launcher',
      color: transaction.type == 'Income' 
          ? const Color(0xFF4CAF50)  // Green
          : const Color(0xFFF44336),  // Red
      enableVibration: true,
      playSound: true,
      actions: [
        const AndroidNotificationAction(
          'confirm',
          '✓ Confirm',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_check'),
          showsUserInterface: false,  // Don't open app
          cancelNotification: true,    // Auto-dismiss after action
        ),
        const AndroidNotificationAction(
          'edit',
          '✎ Edit',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_edit'),
          showsUserInterface: true,    // Open app for editing
        ),
        const AndroidNotificationAction(
          'discard',
          '✕ Discard',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_close'),
          showsUserInterface: false,   // Don't open app
          cancelNotification: true,    // Auto-dismiss
        ),
      ],
    );

    await _notifications.show(
      transaction.hashCode,
      _buildNotificationTitle(transaction),
      _buildNotificationBody(transaction),
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  String _buildNotificationTitle(TransactionData transaction) {
    final icon = transaction.type == 'Income' ? '📥' : '📤';
    return '$icon ₹${transaction.amount.toStringAsFixed(2)} ${transaction.type}';
  }

  String _buildNotificationBody(TransactionData transaction) {
    final parts = <String>[];
    
    if (transaction.merchant != null) {
      parts.add('<b>${transaction.merchant}</b>');
    }
    
    if (transaction.accountNumber != null) {
      parts.add('A/c: ${transaction.accountNumber}');
    }
    
    if (transaction.referenceNumber != null) {
      parts.add('Ref: ${transaction.referenceNumber}');
    }
    
    return parts.isEmpty ? 'Transaction detected' : parts.join(' • ');
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
