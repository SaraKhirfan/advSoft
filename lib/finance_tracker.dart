import 'package:flutter/foundation.dart';
import 'transaction_result.dart';

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
  double _totalIncome; // Renamed from totalBudget to better reflect its purpose

  // Fixed budget amounts - only changes when income changes
  final Map<ExpenseCategory, double> _categoryBudgets = {};

  // Percentages for each category based on rule type
  final Map<ExpenseCategory, double> _categoryPercentages = {};

  BudgetRule(this.type, this._totalIncome) {
    _initializePercentages();
    _initializeBudgets();
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

  void _initializeBudgets() {
    _categoryPercentages.forEach((category, percentage) {
      _categoryBudgets[category] = _totalIncome * percentage;
    });
  }

  // Returns the total income
  double get totalIncome => _totalIncome;

  // Returns the fixed budget amount for a category
  double getCategoryBudget(ExpenseCategory category) {
    return _categoryBudgets[category] ?? 0.0;
  }

  // Returns the percentage allocation for a category
  double getCategoryPercentage(ExpenseCategory category) {
    return _categoryPercentages[category] ?? 0.0;
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

  // Called when new income is added
  void distributeIncome(double amount) {
    // Increase total income
    _totalIncome += amount;

    // Distribute the new income to each category based on percentages
    _categoryPercentages.forEach((category, percentage) {
      // Add to the budget for this category
      _categoryBudgets[category] = (_categoryBudgets[category] ?? 0.0) + (amount * percentage);
    });
  }

  // Check if there's enough available budget (budget - spent) for a transaction
  bool canDeductFromCategory(ExpenseCategory category, double amount, double currentSpent) {
    double budget = _categoryBudgets[category] ?? 0.0;
    double available = budget - currentSpent;
    return available >= amount;
  }
}

class Transaction {
  final TransactionType type;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseCategory? expenseCategory;

  Transaction({
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    this.expenseCategory,
    DateTime? date, required DateTime timestamp,
  }) : date = date ?? DateTime.now();
}

class FinanceTracker with ChangeNotifier {
  double _totalBalance = 0.0;
  final List<Transaction> _transactions = [];
  BudgetRule? _budgetRule;

  double get totalBalance => _totalBalance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BudgetRule? get budgetRule => _budgetRule;

  // Set initial budget and create budget rule
  void setInitialBudget(double amount, BudgetRuleType ruleType) {
    _totalBalance = amount;
    _budgetRule = BudgetRule(ruleType, amount);
    _transactions.clear();
    notifyListeners();
  }

  TransactionResult addTransaction(Transaction transaction) {
    if (_budgetRule == null) return TransactionResult(success: false);

    if (transaction.type == TransactionType.income) {
      // Handle income transaction
      _budgetRule!.distributeIncome(transaction.amount);
      _totalBalance += transaction.amount;
      _transactions.insert(0, transaction);
      notifyListeners();
      return TransactionResult(success: true);
    } else {
      // Handle expense transaction
      if (transaction.expenseCategory == null) {
        return TransactionResult(success: false);
      }

      // Get current spent amount for this category
      double currentSpent = getTotalExpensesByCategory(transaction.expenseCategory!);

      // Check if we have enough in the category before allowing the transaction
      if (!_budgetRule!.canDeductFromCategory(
          transaction.expenseCategory!, transaction.amount, currentSpent)) {
        String categoryName = _budgetRule!.getCategoryName(transaction.expenseCategory!);
        return TransactionResult(
          success: false,
          showAlert: true,
          alertMessage: 'Cannot exceed budget limit for $categoryName category.',
          categoryName: categoryName,
        );
      }

      // Calculate usage percentage after this transaction
      double budget = _budgetRule!.getCategoryBudget(transaction.expenseCategory!);
      double newSpent = currentSpent + transaction.amount;
      double newPercentage = (newSpent / budget) * 100;

      // Add the transaction - no deduction from budget, just add to transactions list
      _totalBalance -= transaction.amount;
      _transactions.insert(0, transaction);
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

  // Calculate total income
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  // Calculate total expenses
  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  // Get the total spent amount for a specific category
  double getTotalExpensesByCategory(ExpenseCategory category) {
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
        t.expenseCategory == category)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get the available amount for a category (budget - spent)
  double getAvailableAmountForCategory(ExpenseCategory category) {
    double budget = _budgetRule?.getCategoryBudget(category) ?? 0.0;
    double spent = getTotalExpensesByCategory(category);
    return budget - spent;
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