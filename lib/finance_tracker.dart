import 'package:flutter/foundation.dart';
import 'transaction_result.dart';
import 'services/budget_service.dart';
import 'services/transaction_service.dart';

enum TransactionType { expense, income }

enum BudgetRuleType {
  rule_503020,  // 50/30/20 Rule
  rule_702010,  // 70/20/10 Rule
  rule_303010   // 30/30/30/10 Rule
}

enum ExpenseCategory {
  // 50/30/20 Rule
  needs,
  wants,
  savings,

  // 70/20/10 Rule
  living,
  savingsWealth,
  debtCharity,

  // 30/30/30/10 Rule
  housing,
  livingExpenses,
  financialGoals,
  discretionary
}

class BudgetRule {
  final BudgetRuleType type;
  double _initialBudget; // Renamed from totalIncome to initialBudget

  // Percentages for each category based on rule type
  final Map<ExpenseCategory, double> _categoryPercentages = {};

  BudgetRule(this.type, this._initialBudget) {
    _initializePercentages();
  }

  void _initializePercentages() {
    switch (type) {
      case BudgetRuleType.rule_503020:
        _categoryPercentages[ExpenseCategory.needs] = 0.5;    // 50% Needs
        _categoryPercentages[ExpenseCategory.wants] = 0.3;    // 30% Wants
        _categoryPercentages[ExpenseCategory.savings] = 0.2;  // 20% Savings
        break;
      case BudgetRuleType.rule_702010:
        _categoryPercentages[ExpenseCategory.living] = 0.7;         // 70% Living
        _categoryPercentages[ExpenseCategory.savingsWealth] = 0.2;  // 20% Savings
        _categoryPercentages[ExpenseCategory.debtCharity] = 0.1;    // 10% Debt/Charity
        break;
      case BudgetRuleType.rule_303010:
        _categoryPercentages[ExpenseCategory.housing] = 0.3;         // 30% Housing
        _categoryPercentages[ExpenseCategory.livingExpenses] = 0.3;  // 30% Living
        _categoryPercentages[ExpenseCategory.financialGoals] = 0.3;  // 30% Goals
        _categoryPercentages[ExpenseCategory.discretionary] = 0.1;   // 10% Wants
        break;
    }
  }

  // Returns the initial budget amount
  double get totalIncome => _initialBudget;

  // Returns the budget amount for a category based on the initial budget
  double getCategoryBudget(ExpenseCategory category) {
    return _initialBudget * (_categoryPercentages[category] ?? 0.0);
  }

  // Returns the percentage allocation for a category
  double getCategoryPercentage(ExpenseCategory category) {
    return _categoryPercentages[category] ?? 0.0;
  }

  // Get all categories for this budget rule type
  List<ExpenseCategory> getCategories() {
    return _categoryPercentages.keys.toList();
  }

  // Returns the display name for the budget rule
  String getDisplayName() {
    switch (type) {
      case BudgetRuleType.rule_503020:
        return '50/30/20 Rule';
      case BudgetRuleType.rule_702010:
        return '70/20/10 Rule';
      case BudgetRuleType.rule_303010:
        return '30/30/30/10 Rule';
    }
  }

  // Returns the human-readable name for a category
  String getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.needs:
        return 'Essential Needs';
      case ExpenseCategory.wants:
        return 'Lifestyle Wants';
      case ExpenseCategory.savings:
        return 'Savings/Debt';
      case ExpenseCategory.living:
        return 'Living Expenses';
      case ExpenseCategory.savingsWealth:
        return 'Wealth Building';
      case ExpenseCategory.debtCharity:
        return 'Debt/Charity';
      case ExpenseCategory.housing:
        return 'Housing';
      case ExpenseCategory.livingExpenses:
        return 'Living Expenses';
      case ExpenseCategory.financialGoals:
        return 'Financial Goals';
      case ExpenseCategory.discretionary:
        return 'Discretionary';
      default:
        return 'Unknown';
    }
  }

  // Returns a description of the budgeting rule
  String getRuleDescription() {
    switch (type) {
      case BudgetRuleType.rule_503020:
        return '50% Needs: Essential expenses\n30% Wants: Lifestyle enhancements\n20% Savings: Financial future';
      case BudgetRuleType.rule_702010:
        return '70% Living: Combined needs & wants\n20% Savings: Wealth building\n10% Debt/Charity: Giving back';
      case BudgetRuleType.rule_303010:
        return '30% Housing: Rent/mortgage\n30% Living: Daily expenses\n30% Goals: Financial planning\n10% Wants: Personal spending';
    }
  }

  void updateInitialBudget(double newAmount) {
    _initialBudget = newAmount;
  }

  bool canDeductFromCategory(ExpenseCategory category, double amount, double currentSpent) {
    double budget = getCategoryBudget(category);
    double available = budget - currentSpent;
    return available >= amount;
  }
}

class Transaction {
  final String? id;
  final TransactionType type;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseCategory? expenseCategory;
  final DateTime timestamp;

  Transaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    this.expenseCategory,
    DateTime? date,
    DateTime? timestamp,
  }) :
        this.date = date ?? DateTime.now(),
        this.timestamp = timestamp ?? DateTime.now();
}

// Update the FinanceTracker class
class FinanceTracker with ChangeNotifier {
  double _totalBalance = 0.0;
  final List<Transaction> _transactions = [];
  BudgetRule? _budgetRule;

  // Add Firebase service instances
  final BudgetService _budgetService = BudgetService();
  final TransactionService _transactionService = TransactionService();

  double get totalBalance => _totalBalance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BudgetRule? get budgetRule => _budgetRule;

  Future<void> initializeFromFirebase() async {
    try {
      // Load budget rule
      final budgetRule = await _budgetService.getBudgetRule();
      if (budgetRule != null) {
        _budgetRule = budgetRule;
      }

      // Load transactions
      final transactions = await _transactionService.getUserTransactions();
      _transactions.clear();
      _transactions.addAll(transactions);

      // Calculate current balance
      await _recalculateBalance();

      notifyListeners();
    } catch (e) {
      print('Error initializing from Firebase: $e');
      // Handle errors
      rethrow;
    }
  }

  Future<void> _recalculateBalance() async {
    if (_budgetRule == null) return;

    // Get initial budget
    double initialBudget = _budgetRule!.totalIncome;

    // Calculate total income and expenses from transactions
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    // Set the total balance
    _totalBalance = initialBudget + totalIncome - totalExpenses;
  }

  Future<bool> removeTransaction(String transactionId) async {
    try {
      // First get the transaction to know its type and amount
      final transaction = _transactions.firstWhere(
            (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      // Delete from Firestore
      bool success = await _transactionService.deleteTransaction(transactionId);
      if (!success) return false;

      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);

      // Update balance based on transaction type
      if (transaction.type == TransactionType.income) {
        _totalBalance -= transaction.amount;
      } else {
        _totalBalance += transaction.amount;
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error removing transaction: $e');
      return false;
    }
  }

  // Set transactions from Firebase (called from HomePage) - Updated
  void setTransactions(List<Transaction> transactions) {
    _transactions.clear();
    _transactions.addAll(transactions);
    _recalculateBalance(); // Recalculate balance when transactions change
    notifyListeners();
  }

  // Set budget rule (called from HomePage) - Updated
  void setBudgetRule(BudgetRule budgetRule) {
    _budgetRule = budgetRule;
    _recalculateBalance(); // Recalculate balance when budget rule changes
    notifyListeners();
  }

  // Start listening to transaction changes - Updated
  void startTransactionListener() {
    _transactionService.streamUserTransactions().listen((transactions) {
      _transactions.clear();
      _transactions.addAll(transactions);
      _recalculateBalance(); // Recalculate balance when transactions change
      notifyListeners();
    }, onError: (error) {
      print('Error in transaction stream: $error');
    });
  }

  // Set initial budget and create budget rule - Updated
  Future<void> setInitialBudget(double amount, BudgetRuleType ruleType) async {
    // Save to Firebase
    await _budgetService.saveBudgetRule(amount, ruleType);

    // Update local state
    _budgetRule = BudgetRule(ruleType, amount);
    _totalBalance = amount;
    _transactions.clear();
    notifyListeners();
  }

  // Add transaction - Updated
  Future<TransactionResult> addTransaction(Transaction transaction) async {
    if (_budgetRule == null) return TransactionResult(success: false);

    if (transaction.type == TransactionType.income) {
      // Save to Firebase first
      String? transactionId = await _transactionService.addTransaction(transaction);
      if (transactionId == null) {
        return TransactionResult(
            success: false,
            showAlert: true,
            alertMessage: "Failed to save transaction to database."
        );
      }

      // Create a new transaction with the ID
      final newTransaction = Transaction(
        id: transactionId,
        type: transaction.type,
        category: transaction.category,
        amount: transaction.amount,
        description: transaction.description,
        expenseCategory: transaction.expenseCategory,
        date: transaction.date,
        timestamp: transaction.timestamp,
      );

      // Add to local state
      _totalBalance += transaction.amount;
      _transactions.insert(0, newTransaction);
      notifyListeners();
      return TransactionResult(success: true);
    } else {
      // Handle expense transaction
      if (transaction.expenseCategory == null) {
        return TransactionResult(success: false);
      }

      // Get current spent amount for this category
      double currentSpent = getTotalExpensesByCategory(transaction.expenseCategory!);

      // Get category budget based on current total
      double categoryBudget = _budgetRule!.getCategoryBudget(transaction.expenseCategory!);

      // Check if we have enough in the category before allowing the transaction
      if (currentSpent + transaction.amount > categoryBudget) {
        String categoryName = _budgetRule!.getCategoryName(transaction.expenseCategory!);
        return TransactionResult(
          success: false,
          showAlert: true,
          alertMessage: 'Cannot exceed budget limit for $categoryName category.',
          categoryName: categoryName,
        );
      }

      // Save to Firebase first
      String? transactionId = await _transactionService.addTransaction(transaction);
      if (transactionId == null) {
        return TransactionResult(
            success: false,
            showAlert: true,
            alertMessage: "Failed to save transaction to database."
        );
      }

      // Create a new transaction with the ID
      final newTransaction = Transaction(
        id: transactionId,
        type: transaction.type,
        category: transaction.category,
        amount: transaction.amount,
        description: transaction.description,
        expenseCategory: transaction.expenseCategory,
        date: transaction.date,
        timestamp: transaction.timestamp,
      );

      // Calculate usage percentage after this transaction
      double newSpent = currentSpent + transaction.amount;
      double newPercentage = (newSpent / categoryBudget) * 100;

      // Add the transaction to local state
      _totalBalance -= transaction.amount;
      _transactions.insert(0, newTransaction);
      notifyListeners();

      // Determine if any alerts should be shown based on budget usage
      String categoryName = _budgetRule!.getCategoryName(transaction.expenseCategory!);
      if (newPercentage >= 90) {
        return TransactionResult(
          success: true,
          showAlert: true,
          alertMessage: 'Warning: You have almost depleted your $categoryName budget.\nCurrent usage: ${newPercentage.toStringAsFixed(1)}%',
          categoryName: categoryName,
        );
      } else if (newPercentage >= 75) {
        return TransactionResult(
          success: true,
          showAlert: true,
          alertMessage: 'Caution: You are using a lot of your $categoryName budget.\nCurrent usage: ${newPercentage.toStringAsFixed(1)}%',
          categoryName: categoryName,
        );
      }

      return TransactionResult(success: true);
    }
  }

  // Get the current balance - Updated
  double getCurrentBalance() {
    return _totalBalance;
  }

  // Calculate total income - Unchanged
  double getTotalIncome() => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  // Calculate total expenses - Unchanged
  double getTotalExpenses() => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  // Get the total spent amount for a specific category - Unchanged
  double getTotalExpensesByCategory(ExpenseCategory category) {
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
        t.expenseCategory == category)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get the available amount for a category (budget - spent) - Updated
  double getAvailableAmountForCategory(ExpenseCategory category) {
    if (_budgetRule == null) return 0.0;

    // Get the current category budget based on current total balance
    double categoryBudget = _budgetRule!.getCategoryBudget(category);
    double spent = getTotalExpensesByCategory(category);
    return categoryBudget - spent;
  }

  // Map transaction category to expense category
  ExpenseCategory mapTransactionToExpenseCategory(String category, BudgetRuleType ruleType) {
    category = category.toLowerCase();
    switch (ruleType) {
      case BudgetRuleType.rule_503020:
        switch (category) {
          case 'food':
          case 'transport':
          case 'bills':
          case 'health':
          case 'rent':
            return ExpenseCategory.needs;
          case 'entertainment':
          case 'shopping':
            return ExpenseCategory.wants;
          default:
            return ExpenseCategory.savings;
        }
      case BudgetRuleType.rule_702010:
        switch (category) {
          case 'food':
          case 'transport':
          case 'bills':
          case 'health':
          case 'rent':
          case 'entertainment':
          case 'shopping':
            return ExpenseCategory.living;
          case 'investment':
            return ExpenseCategory.savingsWealth;
          default:
            return ExpenseCategory.debtCharity;
        }
      case BudgetRuleType.rule_303010:
        switch (category) {
          case 'rent':
            return ExpenseCategory.housing;
          case 'food':
          case 'transport':
          case 'bills':
          case 'health':
            return ExpenseCategory.livingExpenses;
          case 'investment':
          case 'savings':
            return ExpenseCategory.financialGoals;
          case 'entertainment':
          case 'shopping':
            return ExpenseCategory.discretionary;
          default:
            return ExpenseCategory.livingExpenses;
        }
    }
  }

  // Get budget status message for a category
  String getBudgetStatusMessage(ExpenseCategory category) {
    if (_budgetRule == null) return '';

    double budget = _budgetRule!.getCategoryBudget(category);
    double spent = getTotalExpensesByCategory(category);
    double available = budget - spent;
    String categoryName = _budgetRule!.getCategoryName(category);

    // Calculate percentage of budget used
    double percentageUsed = (spent / budget) * 100;

    if (percentageUsed >= 100) {
      return 'You have exceeded your $categoryName budget! Current usage: ${percentageUsed.toStringAsFixed(1)}%';
    } else if (percentageUsed >= 90) {
      return 'Warning: You have almost depleted your $categoryName budget. Current usage: ${percentageUsed.toStringAsFixed(1)}%';
    } else if (percentageUsed >= 75) {
      return 'Caution: You are using a lot of your $categoryName budget. Current usage: ${percentageUsed.toStringAsFixed(1)}%';
    } else {
      return 'You are managing your $categoryName budget well. Current usage: ${percentageUsed.toStringAsFixed(1)}%';
    }
  }
}