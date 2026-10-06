import 'package:expenses_tracker/pages/categories_page.dart';
import 'package:expenses_tracker/pages/subcategories_page.dart';
import 'package:expenses_tracker/pages/userprofile_page.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import '../utils/widgets/app_bars.dart';
import '../services/sms_service.dart';
import '../widgets/transaction_confirmation_dialog.dart';

import 'package:expenses_tracker/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SmsService _smsService = SmsService();
  bool _hasPermission = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _smsService.checkPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _requestPermission() async {
    await _smsService.requestPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkPermission();
  }

  Future<void> _scanHistoricalSms() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final transactions = await _smsService.scanHistoricalSms(limit: 500);
      
      if (!mounted) return;
      
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No bank transactions found in SMS')),
        );
      } else {
        // Show list of transactions to import
        showDialog(
          context: context,
          builder: (context) => _ImportTransactionsDialog(transactions: transactions),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning SMS: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MinimalAppBar(title: 'Settings'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Theme section
            Card(
              child: AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) {
                  final current = ThemeController.instance.mode;
                  final dark = current == ThemeMode.dark;
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: dark,
                    onChanged: (val) => ThemeController.instance.toggle(val),
                    secondary: const Icon(Icons.brightness_6),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            
            // SMS Auto-import section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.sms),
                    title: const Text('SMS Auto-import'),
                    subtitle: Text(_hasPermission 
                      ? 'Bank transactions will be auto-detected'
                      : 'Enable to auto-import transactions'),
                    trailing: Switch(
                      value: _hasPermission,
                      onChanged: (val) {
                        if (val) {
                          _requestPermission();
                        }
                      },
                    ),
                  ),
                  if (_hasPermission) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Import from SMS History'),
                      subtitle: const Text('Scan past SMS for transactions'),
                      trailing: _isScanning
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                      onTap: _isScanning ? null : _scanHistoricalSms,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Quick links - responsive wrap
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int columns = 2;
                if (width >= 900) columns = 3; // desktop
                if (width < 360) columns = 1;   // very narrow
                const spacing = 12.0;
                final itemWidth = (width - spacing * (columns - 1)) / columns;

                Widget linkCard(IconData icon, String label, VoidCallback onTap) {
                  return SizedBox(
                    width: itemWidth,
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, size: 32),
                              const SizedBox(height: 10),
                              Text(label, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    linkCard(
                      Icons.person,
                      'User Profile',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfilePage()),
                      ),
                    ),
                    linkCard(
                      Icons.category,
                      'Categories',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoriesPage()),
                      ),
                    ),
                    linkCard(
                      Icons.subdirectory_arrow_right,
                      'Subcategories',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubcategoriesPage()),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 60),
            TextScroll(
              textAlign: TextAlign.end,
              'Daily Expenses Tracker developed By Kumar Sundaram. Copyright © 2025. All rights reserved.',
              velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
              delayBefore: const Duration(milliseconds: 500),
              pauseBetween: const Duration(milliseconds: 50),
              style: Theme.of(context).textTheme.bodySmall,
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportTransactionsDialog extends StatelessWidget {
  final List transactions;

  const _ImportTransactionsDialog({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${transactions.length} Transactions Found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            tx.type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tx.type == 'Income' ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${tx.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  tx.merchant ?? tx.type,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => TransactionConfirmationDialog(
                                  transaction: tx,
                                ),
                              ).then((imported) {
                                if (imported == true) {
                                  Navigator.pop(context);
                                }
                              });
                            },
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
