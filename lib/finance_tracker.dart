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
  final double totalBudget;
  final Map<ExpenseCategory, double> _categoryBalances = {};
  final Map<ExpenseCategory, double> _categoryPercentages = {};

  BudgetRule(this.type, this.totalBudget) {
    _initializePercentages();
    _initializeBalances();
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

  void _initializeBalances() {
    _categoryPercentages.forEach((category, percentage) {
      _categoryBalances[category] = totalBudget * percentage;
    });
  }

  double getCategoryBudget(ExpenseCategory category) {
    return _categoryBalances[category] ?? 0.0;
  }

  double getCategoryPercentage(ExpenseCategory category) {
    return _categoryPercentages[category] ?? 0.0;
  }

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

  void distributeIncome(double amount) {
    _categoryPercentages.forEach((category, percentage) {
      _categoryBalances[category] = (_categoryBalances[category] ?? 0.0) + (amount * percentage);
    });
  }

  bool canDeductFromCategory(ExpenseCategory category, double amount) {
    return (_categoryBalances[category] ?? 0.0) >= amount;
  }

  void deductFromCategory(ExpenseCategory category, double amount) {
    if (_categoryBalances.containsKey(category)) {
      _categoryBalances[category] = (_categoryBalances[category] ?? 0.0) - amount;
    }
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
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

class FinanceTracker with ChangeNotifier {
  double _balance = 0.0;
  final List<Transaction> _transactions = [];
  BudgetRule? _budgetRule;

  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BudgetRule? get budgetRule => _budgetRule;

  // Set initial budget and create budget rule
  void setInitialBudget(double amount, BudgetRuleType ruleType) {
    _balance = amount;
    _budgetRule = BudgetRule(ruleType, amount);
    _transactions.clear();
    notifyListeners();
  }

  TransactionResult addTransaction(Transaction transaction) {
    if (_budgetRule == null) return TransactionResult(success: false);

    if (transaction.type == TransactionType.income) {
      _budgetRule!.distributeIncome(transaction.amount);
      _balance += transaction.amount;
      _transactions.insert(0, transaction);
      notifyListeners();
      return TransactionResult(success: true);
    } else {
      if (transaction.expenseCategory == null) {
        return TransactionResult(success: false);
      }

      // Check if we have enough in the category before allowing the transaction
      if (!_budgetRule!.canDeductFromCategory(transaction.expenseCategory!, transaction.amount)) {
        String categoryName = _budgetRule!.getCategoryName(transaction.expenseCategory!);
        return TransactionResult(
          success: false,
          showAlert: true,
          alertMessage: 'Cannot exceed budget limit for $categoryName category.',
          categoryName: categoryName,
        );
      }

      // Calculate usage percentage after transaction
      double currentAmount = getExpensesByCategory(transaction.expenseCategory!);
      double maxAmount = _budgetRule!.getCategoryBudget(transaction.expenseCategory!);
      double newPercentage = ((currentAmount + transaction.amount) / maxAmount) * 100;

      _budgetRule!.deductFromCategory(transaction.expenseCategory!, transaction.amount);
      _balance -= transaction.amount;
      _transactions.insert(0, transaction);
      notifyListeners();

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

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  // Get expenses by category
  double getExpensesByCategory(ExpenseCategory category) {
    double totalExpenses = _transactions
        .where((t) => t.type == TransactionType.expense &&
        t.expenseCategory == category)
        .fold(0, (sum, t) => sum + t.amount);

    // Return the remaining budget for this category
    double categoryBudget = _budgetRule?.getCategoryBudget(category) ?? 0.0;
    return categoryBudget - totalExpenses;
  }

  // Get total expenses by category
  double getTotalExpensesByCategory(ExpenseCategory category) {
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
        t.expenseCategory == category)
        .fold(0, (sum, t) => sum + t.amount);
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


  // Get budget status message
  String getBudgetStatusMessage(ExpenseCategory category) {
    if (_budgetRule == null) return '';

    double budget = _budgetRule!.getCategoryBudget(category);
    double spent = getExpensesByCategory(category);
    String categoryName = _budgetRule!.getCategoryName(category);
    double percentage = (spent / budget) * 100;

    if (percentage >= 100) {
      return 'You have exceeded your $categoryName budget! Current usage: ${percentage.toStringAsFixed(1)}%';
    } else if (percentage >= 90) {
      return 'Warning: You have almost depleted your $categoryName budget. Current usage: ${percentage.toStringAsFixed(1)}%';
    } else if (percentage >= 75) {
      return 'Caution: You are using a lot of your $categoryName budget. Current usage: ${percentage.toStringAsFixed(1)}%';
    } else {
      return 'You are managing your $categoryName budget well. Current usage: ${percentage.toStringAsFixed(1)}%';
    }
  }
}