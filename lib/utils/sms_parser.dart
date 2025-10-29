import 'package:intl/intl.dart';

class TransactionData {
  final double amount;
  final String type; // 'Expense' or 'Income'
  final String? merchant;
  final DateTime date;
  final String? accountNumber;
  final String? referenceNumber;
  final String rawMessage;

  TransactionData({
    required this.amount,
    required this.type,
    this.merchant,
    required this.date,
    this.accountNumber,
    this.referenceNumber,
    required this.rawMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'merchant': merchant,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'accountNumber': accountNumber,
      'referenceNumber': referenceNumber,
      'rawMessage': rawMessage,
    };
  }
}

class SmsParser {
  static TransactionData? parse(String message, int timestamp) {
    final lowerMessage = message.toLowerCase();
    
    // Check if it's a transaction message
    if (!_isTransactionMessage(lowerMessage)) {
      return null;
    }

    // Determine transaction type
    String? type;
    if (_isDebit(lowerMessage)) {
      type = 'Expense';
    } else if (_isCredit(lowerMessage)) {
      type = 'Income';
    }

    if (type == null) return null;

    // Extract amount
    final amount = _extractAmount(message);
    if (amount == null || amount <= 0) return null;

    // Extract merchant/description
    final merchant = _extractMerchant(message);

    // Extract account number
    final accountNumber = _extractAccountNumber(message);

    // Extract reference number
    final referenceNumber = _extractReferenceNumber(message);

    // Use timestamp for date
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return TransactionData(
      amount: amount,
      type: type,
      merchant: merchant,
      date: date,
      accountNumber: accountNumber,
      referenceNumber: referenceNumber,
      rawMessage: message,
    );
  }

  static bool _isTransactionMessage(String message) {
    final transactionKeywords = [
      'debited', 'credited', 'withdrawn', 'deposited',
      'paid', 'received', 'transaction', 'transfer',
      'sent to', 'received from', 'upi',
    ];
    return transactionKeywords.any((keyword) => message.contains(keyword));
  }

  static bool _isDebit(String message) {
    final debitKeywords = [
      'debited', 'withdrawn', 'paid', 'spent',
      'sent to', 'purchase', 'deducted', 'dr '
    ];
    return debitKeywords.any((keyword) => message.contains(keyword));
  }

  static bool _isCredit(String message) {
    final creditKeywords = [
      'credited', 'deposited', 'received',
      'received from', 'refund', 'cashback', 'cr '
    ];
    return creditKeywords.any((keyword) => message.contains(keyword));
  }

  static double? _extractAmount(String message) {
    // Patterns to match amounts
    final patterns = [
      RegExp(r'(?:rs\.?|inr|₹)\s*(\d+(?:,\d+)*(?:\.\d{1,2})?)', caseSensitive: false),
      RegExp(r'(\d+(?:,\d+)*(?:\.\d{1,2})?)\s*(?:rs|inr|₹)', caseSensitive: false),
      RegExp(r'amount:\s*(?:rs\.?|inr|₹)?\s*(\d+(?:,\d+)*(?:\.\d{1,2})?)', caseSensitive: false),
      RegExp(r'(?:of|for)\s+(?:rs\.?|inr|₹)?\s*(\d+(?:,\d+)*(?:\.\d{1,2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(amountStr);
      }
    }

    return null;
  }
  static String? _extractMerchant(String message) {
    // Try to extract merchant name from common patterns
    final patterns = [
      // ICICI Bank pattern: "debited for Rs X on DATE; MERCHANT_NAME credited"
      RegExp(r'debited for Rs[\s\d,\.]+on[^;]+;\s*([A-Za-z0-9\s@\._-]+?)\s+credited', caseSensitive: false),
      // IndusInd Bank patterns: "credited by Rs X from USER@bank" or "debited by Rs X towards USER@bank"
      RegExp(r'(?:credited|debited)\s+by\s+Rs[\s\d,\.]+(?:from|towards)\s+([a-zA-Z0-9\.@_-]+)', caseSensitive: false),
      // Generic UPI patterns
      RegExp(r'(?:to|at|from)\s+([A-Za-z0-9\s@\-\.]+?)(?:\s+on|\s+a/c|\s+ref|\s+upi|\.|\ s+via)', caseSensitive: false),
      RegExp(r'paid to\s+([A-Za-z0-9\s@\-\.]+?)(?:\s+using|\s+via|\s+on)', caseSensitive: false),
      RegExp(r'(?:merchant|vendor):\s*([A-Za-z0-9\s@\-\.]+?)(?:\s|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        String merchant = match.group(1)!.trim();
        
        // Clean up merchant name
        merchant = merchant.replaceAll(RegExp(r'\s+'), ' ');
        
        // Remove trailing punctuation
        merchant = merchant.replaceAll(RegExp(r'[\.,;]+$'), '');
        
        // For UPI IDs, extract the username part before @
        if (merchant.contains('@')) {
          // Extract username from UPI ID (e.g., "tarungk05@okicici" -> "tarungk05")
          final upiMatch = RegExp(r'^([a-zA-Z0-9\.]+)@').firstMatch(merchant);
          if (upiMatch != null) {
            merchant = _formatUpiUsername(upiMatch.group(1)!);
          }
        }
        
        if (merchant.length > 2 && merchant.length < 100) {
          return merchant;
        }
      }
    }

    return null;
  }
  
  // Format UPI username to be more readable
  static String _formatUpiUsername(String username) {
    // Remove common prefixes/suffixes
    username = username.replaceAll(RegExp(r'^(bhqr\.|upi\.)'), '');
    
    // If it looks like a name (has letters and numbers), try to make it readable
    if (RegExp(r'[a-zA-Z]').hasMatch(username)) {
      // Split on numbers, dots, underscores
      final parts = username.split(RegExp(r'[0-9._-]+'));
      final namePart = parts.where((p) => p.isNotEmpty).join(' ');
      if (namePart.isNotEmpty) {
        // Capitalize first letter of each word
        return namePart.split(' ')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ');
      }
    }
    
    return username;
  }

  static String? _extractAccountNumber(String message) {
    final patterns = [
      RegExp(r'a/c\s*(?:no\.?|number)?\s*[xX*]*(\d{4})', caseSensitive: false),
      RegExp(r'account\s*(?:no\.?|number)?\s*[xX*]*(\d{4})', caseSensitive: false),
      RegExp(r'[xX]{4,}(\d{4})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return 'XX${match.group(1)}';
      }
    }

    return null;
  }

  static String? _extractReferenceNumber(String message) {
    final patterns = [
      // RRN (Retrieval Reference Number) - IndusInd, SBI, etc.
      RegExp(r'RRN:?\s*([0-9]{12,})', caseSensitive: false),
      // UPI transaction ID - ICICI and others
      RegExp(r'UPI:?\s*([0-9]{12,})', caseSensitive: false),
      // Generic patterns
      RegExp(r'(?:ref|reference|utr|txn)(?:\s*no\.?|#|:)?\s*([A-Z0-9]{6,})', caseSensitive: false),
      RegExp(r'(?:upi|imps|neft)\s+(?:ref|id):\s*([A-Z0-9]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  static String getCategoryFromMerchant(String? merchant) {
    if (merchant == null) return 'Misc';
    
    final merchantLower = merchant.toLowerCase();
    
    // Food & Dining
    if (merchantLower.contains(RegExp(r'zomato|swiggy|uber\s*eats|food|restaurant|cafe|dominos|pizza|kfc|mcdonalds|burger|starbucks'))) {
      return 'Food';
    }
    
    // Shopping
    if (merchantLower.contains(RegExp(r'amazon|flipkart|myntra|ajio|shoppers|reliance|dmart|big\s*bazaar|mall'))) {
      return 'Personal';
    }
    
    // Transport
    if (merchantLower.contains(RegExp(r'uber|ola|rapido|metro|petrol|fuel|bpcl|iocl|hpcl'))) {
      return 'Travel';
    }
    
    // Entertainment
    if (merchantLower.contains(RegExp(r'netflix|prime|hotstar|spotify|youtube|bookmyshow|pvr|inox'))) {
      return 'Entertainment';
    }
    
    // Bills & Utilities
    if (merchantLower.contains(RegExp(r'electricity|water|gas|phone|airtel|jio|vodafone|bsnl'))) {
      return 'HomeExp';
    }
    
    // Health
    if (merchantLower.contains(RegExp(r'pharma|medical|hospital|doctor|clinic|apollo|fortis'))) {
      return 'Medical';
    }
    
    return 'Misc';
  }
}
