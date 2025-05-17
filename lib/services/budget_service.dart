import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'firebase_service.dart';
import 'package:test_sample/finance_tracker.dart';

class BudgetService {
  // Save budget rule to Firestore
  Future<bool> saveBudgetRule(double amount, BudgetRuleType ruleType) async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot save budget rule: User ID is null');
      return false;
    }

    try {
      print('Saving budget rule: amount=$amount, ruleType=$ruleType');
      // Save to Firestore - only store rule type and initial budget
      await FirebaseService.getUserBudgetDocument().set({
        'userId': FirebaseService.currentUserId,
        'initialBudget': amount,
        'ruleType': ruleType.toString(),
        'createdAt': firestore.FieldValue.serverTimestamp(),
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      print('Budget rule saved successfully');
      return true;
    } catch (e) {
      print('Error saving budget rule: $e');
      return false;
    }
  }

  // Get budget rule from Firestore
  Future<BudgetRule?> getBudgetRule() async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot get budget rule: User ID is null');
      return null;
    }

    try {
      print('Fetching budget rule for user: ${FirebaseService.currentUserId}');
      final budgetDoc = await FirebaseService.getUserBudgetDocument().get();

      // Explicitly return null if no budget document exists
      if (!budgetDoc.exists) {
        print('No budget document exists for user ${FirebaseService.currentUserId}');
        return null;
      }

      final data = budgetDoc.data() as Map<String, dynamic>;

      // Check if required fields exist
      if (!data.containsKey('initialBudget') || !data.containsKey('ruleType')) {
        print('Budget document missing required fields');
        return null;
      }

      // Use initialBudget instead of totalIncome
      final initialBudget = (data['initialBudget'] as num).toDouble();
      final ruleTypeString = data['ruleType'] as String;

      print('Budget rule found: initialBudget=$initialBudget, ruleType=$ruleTypeString');

      BudgetRuleType ruleType;
      if (ruleTypeString.contains('503020')) {
        ruleType = BudgetRuleType.rule_503020;
      } else if (ruleTypeString.contains('702010')) {
        ruleType = BudgetRuleType.rule_702010;
      } else if (ruleTypeString.contains('303010')) {
        ruleType = BudgetRuleType.rule_303010;
      } else {
        print('Unknown rule type: $ruleTypeString, defaulting to 50/30/20');
        ruleType = BudgetRuleType.rule_503020;
      }

      return BudgetRule(ruleType, initialBudget);
    } catch (e) {
      print('Error getting budget rule: $e');
      return null;
    }
  }

  // Delete budget rule from Firestore
  Future<bool> deleteBudgetRule() async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot delete budget rule: User ID is null');
      return false;
    }

    try {
      print('Deleting budget rule for user: ${FirebaseService.currentUserId}');
      await FirebaseService.getUserBudgetDocument().delete();
      print('Budget rule deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting budget rule: $e');
      return false;
    }
  }

  // Update budget amount without changing rule type
  Future<bool> updateBudgetAmount(double newAmount) async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot update budget amount: User ID is null');
      return false;
    }

    try {
      print('Updating budget amount to: $newAmount');
      // First check if budget rule exists
      final budgetDoc = await FirebaseService.getUserBudgetDocument().get();

      if (!budgetDoc.exists) {
        print('No budget document exists to update');
        return false;
      }

      final data = budgetDoc.data() as Map<String, dynamic>;
      final ruleTypeString = data['ruleType'] as String;

      // Update only the amount
      await FirebaseService.getUserBudgetDocument().update({
        'initialBudget': newAmount,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      print('Budget amount updated successfully');
      return true;
    } catch (e) {
      print('Error updating budget amount: $e');
      return false;
    }
  }

  // Get total income from transactions
  Future<double> getTotalIncomeFromTransactions() async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot get total income: User ID is null');
      return 0.0;
    }

    try {
      print('Calculating total income from transactions');
      final querySnapshot = await FirebaseService.transactionsCollection
          .where('userId', isEqualTo: FirebaseService.currentUserId)
          .where('type', isEqualTo: 'TransactionType.income')
          .get();

      double totalIncome = 0.0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalIncome += (data['amount'] as num).toDouble();
      }

      print('Total income from transactions: $totalIncome');
      return totalIncome;
    } catch (e) {
      print('Error calculating total income: $e');
      return 0.0;
    }
  }

  // Get total expenses from transactions
  Future<double> getTotalExpensesFromTransactions() async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot get total expenses: User ID is null');
      return 0.0;
    }

    try {
      print('Calculating total expenses from transactions');
      final querySnapshot = await FirebaseService.transactionsCollection
          .where('userId', isEqualTo: FirebaseService.currentUserId)
          .where('type', isEqualTo: 'TransactionType.expense')
          .get();

      double totalExpenses = 0.0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalExpenses += (data['amount'] as num).toDouble();
      }

      print('Total expenses from transactions: $totalExpenses');
      return totalExpenses;
    } catch (e) {
      print('Error calculating total expenses: $e');
      return 0.0;
    }
  }

  // Calculate spending for a specific category
  Future<double> getCategorySpending(ExpenseCategory category) async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot get category spending: User ID is null');
      return 0.0;
    }

    try {
      print('Calculating spending for category: $category');
      // Convert enum to string
      String categoryString = category.toString();

      // Query transactions for this category
      final querySnapshot = await FirebaseService.transactionsCollection
          .where('userId', isEqualTo: FirebaseService.currentUserId)
          .where('type', isEqualTo: 'TransactionType.expense')
          .where('expenseCategory', isEqualTo: categoryString)
          .get();

      // Calculate total
      double total = 0.0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num).toDouble();
      }

      print('Category $category spending: $total');
      return total;
    } catch (e) {
      print('Error getting category spending: $e');
      return 0.0;
    }
  }

  // Get all category spending at once
  Future<Map<ExpenseCategory, double>> getAllCategorySpending() async {
    if (FirebaseService.currentUserId == null) {
      print('Cannot get all category spending: User ID is null');
      return {};
    }

    try {
      print('Calculating spending for all categories');
      final querySnapshot = await FirebaseService.transactionsCollection
          .where('userId', isEqualTo: FirebaseService.currentUserId)
          .where('type', isEqualTo: 'TransactionType.expense')
          .get();

      Map<ExpenseCategory, double> categorySpending = {};

      // Initialize all categories to 0
      for (ExpenseCategory category in ExpenseCategory.values) {
        categorySpending[category] = 0.0;
      }

      // Calculate spending from transactions
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('expenseCategory') && data['expenseCategory'] != null) {
          final categoryString = data['expenseCategory'] as String;
          final amount = (data['amount'] as num).toDouble();

          ExpenseCategory? category = _getCategoryFromString(categoryString);
          if (category != null) {
            categorySpending[category] = (categorySpending[category] ?? 0.0) + amount;
          }
        }
      }

      print('All category spending calculated: $categorySpending');
      return categorySpending;
    } catch (e) {
      print('Error calculating all category spending: $e');
      return {};
    }
  }

  // Helper method to convert category string to enum
  ExpenseCategory? _getCategoryFromString(String categoryString) {
    if (categoryString.contains('needs')) return ExpenseCategory.needs;
    if (categoryString.contains('wants')) return ExpenseCategory.wants;
    if (categoryString.contains('savings')) return ExpenseCategory.savings;
    if (categoryString.contains('living')) return ExpenseCategory.living;
    if (categoryString.contains('savingsWealth')) return ExpenseCategory.savingsWealth;
    if (categoryString.contains('debtCharity')) return ExpenseCategory.debtCharity;
    if (categoryString.contains('housing')) return ExpenseCategory.housing;
    if (categoryString.contains('livingExpenses')) return ExpenseCategory.livingExpenses;
    if (categoryString.contains('financialGoals')) return ExpenseCategory.financialGoals;
    if (categoryString.contains('discretionary')) return ExpenseCategory.discretionary;
    return null;
  }

  // This method is deprecated - kept for backward compatibility
  Future<void> updateCategorySpending(ExpenseCategory category, double amount) async {
    print('Warning: updateCategorySpending is deprecated - calculations use transactions');
    return;
  }

  // Get all available budget rule types
  List<BudgetRuleType> getAllBudgetRuleTypes() {
    return [
      BudgetRuleType.rule_503020,
      BudgetRuleType.rule_702010,
      BudgetRuleType.rule_303010,
    ];
  }

  // Get a friendly name for a budget rule type
  String getBudgetRuleTypeName(BudgetRuleType ruleType) {
    switch (ruleType) {
      case BudgetRuleType.rule_503020:
        return '50/30/20 Rule';
      case BudgetRuleType.rule_702010:
        return '70/20/10 Rule';
      case BudgetRuleType.rule_303010:
        return '30/30/30/10 Rule';
      default:
        return 'Custom Rule';
    }
  }

  // Get description for a budget rule type
  String getBudgetRuleTypeDescription(BudgetRuleType ruleType) {
    switch (ruleType) {
      case BudgetRuleType.rule_503020:
        return '50% for needs, 30% for wants, 20% for savings';
      case BudgetRuleType.rule_702010:
        return '70% for living expenses, 20% for savings, 10% for debt/charity';
      case BudgetRuleType.rule_303010:
        return '30% for housing, 30% for living expenses, 30% for financial goals, 10% for discretionary';
      default:
        return 'Custom budget allocation';
    }
  }
}