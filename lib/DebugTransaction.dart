/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'finance_tracker.dart';

class DebugTransactionsScreen extends StatelessWidget {
  const DebugTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<FinanceTracker>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Debug')),
      body: ListView.builder(
        itemCount: tracker.transactions.length,
        itemBuilder: (context, index) {
          final t = tracker.transactions[index];
          return ListTile(
            title: Text('Desc: ${t.description}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${t.category}'),
                Text('Type: ${t.type.toString()}'),
                Text('Amount: JD ${t.amount.toStringAsFixed(2)}'),
                Text('Date: ${DateFormat.yMd().format(t.date)}'),
                if (t.expenseCategory != null)
                  Text('Budget Cat: ${t.expenseCategory.toString()}'),
              ],
            ),
            trailing: Icon(
              t.type == TransactionType.income
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: t.type == TransactionType.income ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }
}*/