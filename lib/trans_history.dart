import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'finance_tracker.dart';
import 'package:intl/intl.dart';
import 'custom_theme.dart';
import 'services/transaction_service.dart';
import 'services/firebase_service.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (FirebaseService.currentUserId == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load transactions from Firebase
      final transactions = await _transactionService.getUserTransactions();

      if (mounted) {
        Provider.of<FinanceTracker>(context, listen: false)
            .setTransactions(transactions);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          backgroundColor: CustomTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          backgroundColor: CustomTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Transactions',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                    'Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: CustomTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
            tooltip: 'Refresh transactions',
          ),
        ],
      ),
      body: Consumer<FinanceTracker>(
        builder: (context, tracker, child) {
          final transactions = tracker.transactions;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your transaction history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              // Sort transactions by date (newest first)
              final sortedTransactions = [...transactions]
                ..sort((a, b) => b.date.compareTo(a.date));

              final transaction = sortedTransactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TransactionCard(
                  transaction: transaction,
                  onDelete: () => _deleteTransaction(transaction),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Transaction has no ID')),
        );
      }
      return;
    }

    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text(
                  'Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                      'Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );

      if (confirm == true) {
        // Delete from Firebase - pass the ID instead of the transaction object
        final success = await _transactionService.deleteTransaction(
            transaction.id!);

        if (!success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete transaction')),
            );
          }
          return;
        }

        // Update local state
        if (mounted) {
          final tracker = Provider.of<FinanceTracker>(context, listen: false);
          // Use removeTransaction with ID
          tracker.removeTransaction(transaction.id!);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting transaction: $e')),
        );
      }
    }
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  IconData _getCategoryIcon() {
    switch (transaction.category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
        return Icons.attach_money;
      case 'freelance':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'business':
        return Icons.business;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'health':
        return Icons.medical_services;
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.water_drop;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'dept payment':
        return Icons.receipt_long;
      case 'emergency funds':
        return Icons.emergency;
      case 'vacations':
        return Icons.beach_access;
      case 'other':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.deepPurple : CustomTheme.accentColor;
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(transaction.date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${isExpense ? '-' : '+'}JOD ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}