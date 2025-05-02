import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'finance_tracker.dart';
import 'custom_theme.dart';
import 'package:test_sample/models/transaction_model.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Track categories separately for expense and income
  String _expenseCategorySelection = '';
  String _incomeCategorySelection = '';
  late ExpenseCategory _selectedExpenseCategory;

  // Add date selection
  DateTime _selectedExpenseDate = DateTime.now();
  DateTime _selectedIncomeDate = DateTime.now();

  // Use tab controller for better state management
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedExpenseCategory = ExpenseCategory.needs;

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to handle state properly
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  final List<CategoryItem> _expenseCategories = [
    CategoryItem(
      name: 'Utilities',
      icon: Icons.water_drop,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.livingExpenses,
    ),
    CategoryItem(
      name: 'Transport',
      icon: Icons.directions_bus,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.livingExpenses,
    ),
    CategoryItem(
      name: 'Groceries',
      icon: Icons.local_grocery_store,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.livingExpenses,
    ),
    CategoryItem(
      name: 'Dept Payment',
      icon: Icons.receipt_long,
      category50_30_20: ExpenseCategory.savings,
      category70_20_10: ExpenseCategory.debtCharity,
      category30_30_30_10: ExpenseCategory.financialGoals,
    ),
    CategoryItem(
      name: 'Rent',
      icon: Icons.home,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
    CategoryItem(
      name: 'Entertainment',
      icon: Icons.movie,
      category50_30_20: ExpenseCategory.wants,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.discretionary,
    ),
    CategoryItem(
      name: 'Vacations',
      icon: Icons.beach_access,
      category50_30_20: ExpenseCategory.wants,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.discretionary,
    ),
    CategoryItem(
      name: 'Emergency Funds',
      icon: Icons.emergency,
      category50_30_20: ExpenseCategory.savings,
      category70_20_10: ExpenseCategory.savingsWealth,
      category30_30_30_10: ExpenseCategory.financialGoals,
    ),
  ];

  final List<CategoryItem> _incomeCategories = [
    CategoryItem(
      name: 'Salary',
      icon: Icons.payments,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
    CategoryItem(
      name: 'Freelance',
      icon: Icons.work,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
    CategoryItem(
      name: 'Investment',
      icon: Icons.trending_up,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
    CategoryItem(
      name: 'Gift',
      icon: Icons.card_giftcard,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
    CategoryItem(
      name: 'Business',
      icon: Icons.business,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
    CategoryItem(
      name: 'Other',
      icon: Icons.category,
      category50_30_20: ExpenseCategory.needs,
      category70_20_10: ExpenseCategory.living,
      category30_30_30_10: ExpenseCategory.housing,
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<CategoryItem> _getCategoriesForType(TransactionType type) {
    return type == TransactionType.expense ? _expenseCategories : _incomeCategories;
  }

  // Helper to get expense category based on selected transaction category and budget rule
  ExpenseCategory _getExpenseCategoryForSelection(String categoryName, BudgetRuleType ruleType) {
    final selectedCategory = _expenseCategories.firstWhere(
            (cat) => cat.name == categoryName,
        orElse: () => _expenseCategories.first
    );

    switch (ruleType) {
      case BudgetRuleType.rule_503020:
        return selectedCategory.category50_30_20;
      case BudgetRuleType.rule_702010:
        return selectedCategory.category70_20_10;
      case BudgetRuleType.rule_303010:
        return selectedCategory.category30_30_30_10;
    }
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context, TransactionType type) async {
    final DateTime initialDate = type == TransactionType.expense
        ? _selectedExpenseDate
        : _selectedIncomeDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: CustomTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        if (type == TransactionType.expense) {
          _selectedExpenseDate = picked;
        } else {
          _selectedIncomeDate = picked;
        }
      });
    }
  }

  Widget _buildExpenseCategorySelector() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Text(
                  'Budget Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CustomTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, color: CustomTheme.primaryColor),
          Consumer<FinanceTracker>(
            builder: (context, tracker, child) {
              if (tracker.budgetRule == null) return const SizedBox.shrink();

              final categories = <MapEntry<ExpenseCategory, Color>>[];

              switch (tracker.budgetRule!.type) {
                case BudgetRuleType.rule_503020:
                  categories.addAll([
                    const MapEntry(ExpenseCategory.needs, CustomTheme.primaryColor),
                    const MapEntry(ExpenseCategory.wants, CustomTheme.primaryLightColor),
                    const MapEntry(ExpenseCategory.savings, CustomTheme.accentColor),
                  ]);
                  break;
                case BudgetRuleType.rule_702010:
                  categories.addAll([
                    const MapEntry(ExpenseCategory.living, CustomTheme.primaryColor),
                    const MapEntry(ExpenseCategory.savingsWealth, CustomTheme.primaryLightColor),
                    const MapEntry(ExpenseCategory.debtCharity, CustomTheme.accentColor),
                  ]);
                  break;
                case BudgetRuleType.rule_303010:
                  categories.addAll([
                    const MapEntry(ExpenseCategory.housing, CustomTheme.primaryColor),
                    const MapEntry(ExpenseCategory.livingExpenses, CustomTheme.primaryLightColor),
                    const MapEntry(ExpenseCategory.financialGoals, CustomTheme.accentColor),
                    MapEntry(ExpenseCategory.discretionary, CustomTheme.primaryColor.withOpacity(0.7)),
                  ]);
                  break;
              }

              // Auto-select the category based on expense selection if one exists
              if (_expenseCategorySelection.isNotEmpty && tracker.budgetRule != null) {
                _selectedExpenseCategory = _getExpenseCategoryForSelection(
                    _expenseCategorySelection,
                    tracker.budgetRule!.type
                );
              } else if (!categories.any((e) => e.key == _selectedExpenseCategory)) {
                _selectedExpenseCategory = categories.first.key;
              }

              return Column(
                children: categories.map((entry) {
                  final category = entry.key;
                  final color = entry.value;
                  final budget = tracker.budgetRule!.getCategoryBudget(category);
                  final spent = tracker.getTotalExpensesByCategory(category);
                  final available = budget - spent;

                  // Determine if this category is the one that will be used for the selected expense
                  bool isSelectedForExpense = _expenseCategorySelection.isNotEmpty &&
                      category == _getExpenseCategoryForSelection(
                          _expenseCategorySelection,
                          tracker.budgetRule!.type
                      );

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelectedForExpense ? color.withOpacity(0.1) : null,
                      border: isSelectedForExpense ? Border.all(color: color.withOpacity(0.3), width: 1) : null,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          if (isSelectedForExpense)
                            Icon(Icons.check_circle, color: color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tracker.budgetRule!.getCategoryName(category),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelectedForExpense ? color : CustomTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                         const Text(
                                            'Budget:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: CustomTheme.primaryLightColor,
                                            ),
                                          ),
                                          Text(
                                            'JOD ${budget.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: CustomTheme.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Spent:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: CustomTheme.primaryLightColor,
                                            ),
                                          ),
                                          Text(
                                            'JOD ${spent.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: CustomTheme.errorColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Available:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: CustomTheme.primaryLightColor,
                                            ),
                                          ),
                                          Text(
                                            'JOD ${available.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: available <= 0
                                                  ? CustomTheme.errorColor
                                                  : CustomTheme.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(TransactionType type) {
    final categories = _getCategoriesForType(type);
    final selection = type == TransactionType.expense
        ? _expenseCategorySelection
        : _incomeCategorySelection;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a category',
            style:  TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CustomTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.name == selection;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (type == TransactionType.expense) {
                      _expenseCategorySelection = category.name;
                    } else {
                      _incomeCategorySelection = category.name;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type == TransactionType.expense
                        ? Colors.deepPurple.withOpacity(0.1)
                        : CustomTheme.successColor.withOpacity(0.1))
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                      color: type == TransactionType.expense
                          ? Colors.deepPurple
                          : CustomTheme.successColor,
                      width: 2,
                    )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        size: 28,
                        color: isSelected
                            ? (type == TransactionType.expense
                              ? Colors.deepPurple
                            : CustomTheme.successColor)
                            : CustomTheme.primaryLightColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (type == TransactionType.expense
                              ? Colors.deepPurple
                              : CustomTheme.successColor)
                              : CustomTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm(TransactionType type) {
    // Get the appropriate date based on transaction type
    final selectedDate = type == TransactionType.expense
        ? _selectedExpenseDate
        : _selectedIncomeDate;

    // Format the date for display
    final formattedDate = DateFormat('MMM d, yyyy').format(selectedDate);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Added spacing before amount input
          const SizedBox(height: 16),

          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: 'JOD ',
              prefixIcon: Icon(
                Icons.money,
                color: type == TransactionType.expense
                    ? Colors.deepPurple
                    : CustomTheme.successColor,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Amount must be greater than zero';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),
          _buildCategoryGrid(type),

          // Added explanatory text between category and budget breakdown
          if (type == TransactionType.expense)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom:
              16),
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CustomTheme.primaryColor.withOpacity(0.1),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: CustomTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your selected category will automatically determine which budget section this expense affects.',
                      style: TextStyle(
                        fontSize: 13,
                        color: CustomTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (type == TransactionType.expense)
            _buildExpenseCategorySelector(),

          // Moved description field to after budget breakdown
          const SizedBox(height: 24),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(
                Icons.description,
                color: type == TransactionType.expense
                    ? Colors.deepPurple
                    : CustomTheme.primaryColor,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),

          // Moved date selection to after description
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _selectDate(context, type),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: type == TransactionType.expense
                        ? Colors.deepPurple
                        : CustomTheme.successColor,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Added extra spacing before the button
          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: type == TransactionType.expense
                  ? Colors.deepPurple
                  : CustomTheme.successColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final selectedCategory = type == TransactionType.expense
                    ? _expenseCategorySelection
                    : _incomeCategorySelection;

                if (selectedCategory.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }

                final amount = double.parse(_amountController.text);
                final description = _descriptionController.text.trim();

                // Get appropriate date based on transaction type
                final timestamp = type == TransactionType.expense
                    ? _selectedExpenseDate
                    : _selectedIncomeDate;

                // For expenses, need to map to the correct budget category
                ExpenseCategory? expenseCategory;
                if (type == TransactionType.expense && Provider.of<FinanceTracker>(context, listen: false).budgetRule != null) {
                  final ruleType = Provider.of<FinanceTracker>(context, listen: false).budgetRule!.type;
                  expenseCategory = _getExpenseCategoryForSelection(selectedCategory, ruleType);
                }

                final result = Provider.of<FinanceTracker>(context, listen: false).addTransaction(
                  Transaction(
                    type: type,
                    category: selectedCategory,
                    expenseCategory: expenseCategory,
                    amount: amount,
                    description: description,
                    timestamp: timestamp,
                  ),
                );

                if (mounted) {
                  Navigator.pop(context);

                  if (!result.success && result.alertMessage != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(type == TransactionType.expense ? 'Expense Error' : 'Income Error'),
                        content: Text(result.alertMessage!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == TransactionType.expense ? Icons.remove : Icons.add,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  type == TransactionType.expense ? 'Add Expense' : 'Add Income',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Added extra spacing after the button
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: CustomTheme.primaryColor,
              unselectedLabelColor: Colors.grey.shade700,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove_circle_outline,  color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text('Expense'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: CustomTheme.successColor ),
                      SizedBox(width: 8),
                      Text('Income'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Expense Form
                SingleChildScrollView(
                  child: _buildTransactionForm(TransactionType.expense),
                ),
                // Income Form
                SingleChildScrollView(
                  child: _buildTransactionForm(TransactionType.income),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}