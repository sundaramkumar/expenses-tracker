// import 'package:isar/isar.dart';

// to generate the isar file
// run in terminal: dart run build_runner build
// part 'expense.g.dart';

// @Collection()
class Expense {
  final int? id;
  final String name;
  final String category;
  final String transactionType;
  final double amount;
  final DateTime date;

  Expense({
    this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.transactionType,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      amount: map['amount'],
      date: map['date'],
      transactionType: map['transactionType'],
    );
  }
}
