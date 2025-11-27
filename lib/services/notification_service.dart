import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Use platform channel to save directly in native code for background
    if (response.payload == null) return;
    
    const platform = MethodChannel('app.channel/notification');
    try {
      platform.invokeMethod('handleNotificationAction', {
        'actionId': response.actionId,
        'payload': response.payload,
      });
    } catch (e) {
      // Error handling native notification action
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
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
      
      switch (response.actionId) {
        case 'confirm':
          onConfirm?.call(transaction);
          break;
        case 'edit':
          onEdit?.call(transaction);
          break;
        case 'discard':
          onDiscard?.call(transaction);
          break;
      }
    } catch (e) {
      // Error handling notification action
    }
  }

  Future<void> showTransactionNotification(TransactionData transaction) async {
    final transactionJson = jsonEncode({
      'amount': transaction.amount,
      'type': transaction.type,
      'merchant': transaction.merchant ?? transaction.type,
      'date': transaction.date.toIso8601String().split('T')[0],
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
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
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
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'edit',
          '✎ Edit',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_edit'),
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'discard',
          '✕ Discard',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_close'),
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    await _notifications.show(
      transaction.hashCode,
      _buildNotificationTitle(transaction),
      _buildNotificationBody(transaction),
      NotificationDetails(android: androidDetails),
      payload: transactionJson,
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
