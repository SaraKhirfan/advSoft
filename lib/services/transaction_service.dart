import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'firebase_service.dart';
import 'budget_service.dart';
import 'package:test_sample/finance_tracker.dart';

class TransactionService {
  final BudgetService _budgetService = BudgetService();

  // Add a new transaction to Firestore - Updated
  Future<String?> addTransaction(Transaction transaction) async {
    if (FirebaseService.currentUserId == null) return null;

    try {
      // Create transaction data
      final Map<String, dynamic> transactionData = {
        'userId': FirebaseService.currentUserId,
        'type': transaction.type.toString(),
        'category': transaction.category,
        'amount': transaction.amount,
        'description': transaction.description,
        'date': firestore.Timestamp.fromDate(transaction.date),
        'timestamp': firestore.FieldValue.serverTimestamp(),
      };

      // Add expense category if it's an expense
      if (transaction.type == TransactionType.expense && transaction.expenseCategory != null) {
        transactionData['expenseCategory'] = transaction.expenseCategory.toString();
      }

      // Add to Firestore and get document reference
      final docRef = await FirebaseService.transactionsCollection.add(transactionData);

      // Return the document ID
      return docRef.id;
    } catch (e) {
      print('Error adding transaction: $e');
      return null;
    }
  }

  // Delete a transaction - Updated
  Future<bool> deleteTransaction(String transactionId) async {
    if (FirebaseService.currentUserId == null) return false;
    if (transactionId.isEmpty) return false;

    try {
      // Delete the transaction document
      await FirebaseService.transactionsCollection.doc(transactionId).delete();
      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  // Get transaction by ID - New method
  Future<Transaction?> getTransactionById(String transactionId) async {
    if (FirebaseService.currentUserId == null) return null;

    try {
      final docSnapshot = await FirebaseService.transactionsCollection.doc(transactionId).get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data() as Map<String, dynamic>;

      // Determine transaction type
      final typeString = data['type'] as String;
      final type = typeString.contains('income')
          ? TransactionType.income
          : TransactionType.expense;

      // Get expense category if available
      ExpenseCategory? expenseCategory;
      if (data.containsKey('expenseCategory') && data['expenseCategory'] != null) {
        final categoryString = data['expenseCategory'] as String;

        if (categoryString.contains('needs')) {
          expenseCategory = ExpenseCategory.needs;
        } else if (categoryString.contains('wants')) {
          expenseCategory = ExpenseCategory.wants;
        } else if (categoryString.contains('savings')) {
          expenseCategory = ExpenseCategory.savings;
        } else if (categoryString.contains('living')) {
          expenseCategory = ExpenseCategory.living;
        } else if (categoryString.contains('savingsWealth')) {
          expenseCategory = ExpenseCategory.savingsWealth;
        } else if (categoryString.contains('debtCharity')) {
          expenseCategory = ExpenseCategory.debtCharity;
        } else if (categoryString.contains('housing')) {
          expenseCategory = ExpenseCategory.housing;
        } else if (categoryString.contains('livingExpenses')) {
          expenseCategory = ExpenseCategory.livingExpenses;
        } else if (categoryString.contains('financialGoals')) {
          expenseCategory = ExpenseCategory.financialGoals;
        } else if (categoryString.contains('discretionary')) {
          expenseCategory = ExpenseCategory.discretionary;
        }
      }

      // Get date
      final timestamp = data['date'] as firestore.Timestamp;
      final date = timestamp.toDate();

      return Transaction(
        id: transactionId,
        type: type,
        category: data['category'] as String,
        amount: (data['amount'] as num).toDouble(),
        description: data['description'] as String,
        expenseCategory: expenseCategory,
        date: date,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error getting transaction: $e');
      return null;
    }
  }

  // Get all transactions for current user - Updated
  Future<List<Transaction>> getUserTransactions() async {
    if (FirebaseService.currentUserId == null) return [];

    try {
      final querySnapshot = await FirebaseService.getUserTransactionsQuery().get();

      List<Transaction> transactions = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Determine transaction type
        final typeString = data['type'] as String;
        final type = typeString.contains('income')
            ? TransactionType.income
            : TransactionType.expense;

        // Get expense category if available
        ExpenseCategory? expenseCategory;
        if (data.containsKey('expenseCategory') && data['expenseCategory'] != null) {
          final categoryString = data['expenseCategory'] as String;

          if (categoryString.contains('needs')) {
            expenseCategory = ExpenseCategory.needs;
          } else if (categoryString.contains('wants')) {
            expenseCategory = ExpenseCategory.wants;
          } else if (categoryString.contains('savings')) {
            expenseCategory = ExpenseCategory.savings;
          } else if (categoryString.contains('living')) {
            expenseCategory = ExpenseCategory.living;
          } else if (categoryString.contains('savingsWealth')) {
            expenseCategory = ExpenseCategory.savingsWealth;
          } else if (categoryString.contains('debtCharity')) {
            expenseCategory = ExpenseCategory.debtCharity;
          } else if (categoryString.contains('housing')) {
            expenseCategory = ExpenseCategory.housing;
          } else if (categoryString.contains('livingExpenses')) {
            expenseCategory = ExpenseCategory.livingExpenses;
          } else if (categoryString.contains('financialGoals')) {
            expenseCategory = ExpenseCategory.financialGoals;
          } else if (categoryString.contains('discretionary')) {
            expenseCategory = ExpenseCategory.discretionary;
          }
        }

        // Get date
        final timestamp = data['date'] as firestore.Timestamp;
        final date = timestamp.toDate();

        // Create transaction with document ID
        transactions.add(Transaction(
          id: doc.id,
          type: type,
          category: data['category'] as String,
          amount: (data['amount'] as num).toDouble(),
          description: data['description'] as String,
          expenseCategory: expenseCategory,
          date: date,
          timestamp: DateTime.now(),
        ));
      }

      return transactions;
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Stream of transactions for real-time updates - Updated
  Stream<List<Transaction>> streamUserTransactions() {
    if (FirebaseService.currentUserId == null) {
      return Stream.value([]);
    }

    return FirebaseService.getUserTransactionsQuery().snapshots().map(
            (querySnapshot) {
          List<Transaction> transactions = [];

          for (var doc in querySnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Determine transaction type
            final typeString = data['type'] as String;
            final type = typeString.contains('income')
                ? TransactionType.income
                : TransactionType.expense;

            // Get expense category if available
            ExpenseCategory? expenseCategory;
            if (data.containsKey('expenseCategory') && data['expenseCategory'] != null) {
              final categoryString = data['expenseCategory'] as String;

              if (categoryString.contains('needs')) {
                expenseCategory = ExpenseCategory.needs;
              } else if (categoryString.contains('wants')) {
                expenseCategory = ExpenseCategory.wants;
              } else if (categoryString.contains('savings')) {
                expenseCategory = ExpenseCategory.savings;
              } else if (categoryString.contains('living')) {
                expenseCategory = ExpenseCategory.living;
              } else if (categoryString.contains('savingsWealth')) {
                expenseCategory = ExpenseCategory.savingsWealth;
              } else if (categoryString.contains('debtCharity')) {
                expenseCategory = ExpenseCategory.debtCharity;
              } else if (categoryString.contains('housing')) {
                expenseCategory = ExpenseCategory.housing;
              } else if (categoryString.contains('livingExpenses')) {
                expenseCategory = ExpenseCategory.livingExpenses;
              } else if (categoryString.contains('financialGoals')) {
                expenseCategory = ExpenseCategory.financialGoals;
              } else if (categoryString.contains('discretionary')) {
                expenseCategory = ExpenseCategory.discretionary;
              }
            }

            // Get date
            final timestamp = data['date'] as firestore.Timestamp;
            final date = timestamp.toDate();

            // Create transaction with document ID
            transactions.add(Transaction(
              id: doc.id,
              type: type,
              category: data['category'] as String,
              amount: (data['amount'] as num).toDouble(),
              description: data['description'] as String,
              expenseCategory: expenseCategory,
              date: date,
              timestamp: DateTime.now(),
            ));
          }

          return transactions;
        }
    );
  }
}