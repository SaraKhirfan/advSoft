import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'finance_tracker.dart';
import 'transaction_result.dart';
import 'custom_theme.dart';

class CategoryItem {
  final String name;
  final IconData icon;

  CategoryItem({required this.name, required this.icon});
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedCategory;
  late ExpenseCategory _selectedExpenseCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'Food';
    _selectedExpenseCategory = ExpenseCategory.needs;
  }

  final List<CategoryItem> _expenseCategories = [
    CategoryItem(name: 'Food', icon: Icons.restaurant),
    CategoryItem(name: 'Transport', icon: Icons.directions_bus),
    CategoryItem(name: 'Entertainment', icon: Icons.movie),
    CategoryItem(name: 'Shopping', icon: Icons.shopping_bag),
    CategoryItem(name: 'Bills', icon: Icons.receipt_long),
    CategoryItem(name: 'Health', icon: Icons.medical_services),
    CategoryItem(name: 'Rent', icon: Icons.home),
    CategoryItem(name: 'Other', icon: Icons.category),
  ];

  final List<CategoryItem> _incomeCategories = [
    CategoryItem(name: 'Salary', icon: Icons.payments),
    CategoryItem(name: 'Freelance', icon: Icons.work),
    CategoryItem(name: 'Investment', icon: Icons.trending_up),
    CategoryItem(name: 'Gift', icon: Icons.card_giftcard),
    CategoryItem(name: 'Business', icon: Icons.business),
    CategoryItem(name: 'Other', icon: Icons.category),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<CategoryItem> _getCategoriesForType(TransactionType type) {
    return type == TransactionType.expense ? _expenseCategories : _incomeCategories;
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
                Icon(Icons.account_balance_wallet, color: CustomTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Budget Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CustomTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Consumer<FinanceTracker>(
            builder: (context, tracker, child) {
              if (tracker.budgetRule == null) return const SizedBox.shrink();

              final categories = <MapEntry<ExpenseCategory, Color>>[];

              switch (tracker.budgetRule!.type) {
                case BudgetRuleType.rule_503020:
                  categories.addAll([
                    MapEntry(ExpenseCategory.needs, CustomTheme.primaryColor),
                    MapEntry(ExpenseCategory.wants, CustomTheme.primaryLightColor),
                    MapEntry(ExpenseCategory.savings, CustomTheme.accentColor),
                  ]);
                  break;
                case BudgetRuleType.rule_702010:
                  categories.addAll([
                    MapEntry(ExpenseCategory.living, CustomTheme.primaryColor),
                    MapEntry(ExpenseCategory.savingsWealth, CustomTheme.primaryLightColor),
                    MapEntry(ExpenseCategory.debtCharity, CustomTheme.accentColor),
                  ]);
                  break;
                case BudgetRuleType.rule_303010:
                  categories.addAll([
                    MapEntry(ExpenseCategory.housing, CustomTheme.primaryColor),
                    MapEntry(ExpenseCategory.livingExpenses, CustomTheme.primaryLightColor),
                    MapEntry(ExpenseCategory.financialGoals, CustomTheme.accentColor),
                    MapEntry(ExpenseCategory.discretionary, CustomTheme.primaryColor.withOpacity(0.7)),
                  ]);
                  break;
              }

              if (!categories.any((e) => e.key == _selectedExpenseCategory)) {
                _selectedExpenseCategory = categories.first.key;
              }

              return Column(
                children: categories.map((entry) {
                  final category = entry.key;
                  final color = entry.value;
                  final budget = tracker.budgetRule!.getCategoryBudget(category);
                  final spent = tracker.getTotalExpensesByCategory(category);
                  final available = budget - spent;

                  return ListTile(
                    title: Text(
                      tracker.budgetRule!.getCategoryName(category),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      'Available: JD ${available.toStringAsFixed(2)}',
                      style: TextStyle(color: color),
                    ),
                    leading: Radio<ExpenseCategory>(
                      value: category,
                      groupValue: _selectedExpenseCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpenseCategory = value!;
                        });
                      },
                      activeColor: color,
                    ),
                    trailing: Icon(Icons.circle, color: color, size: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm(TransactionType type) {
    final categories = _getCategoriesForType(type);
    if (!categories.any((cat) => cat.name == _selectedCategory)) {
      _selectedCategory = categories.first.name;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: Icon(
                    categories.firstWhere((cat) => cat.name == _selectedCategory).icon,
                    color: type == TransactionType.expense ? CustomTheme.errorColor : CustomTheme.accentColor,
                  ),
                  filled: true,
                  fillColor: CustomTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.accentColor),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          color: type == TransactionType.expense ? CustomTheme.errorColor : CustomTheme.accentColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Expense Category Selection (only for expenses)
              if (type == TransactionType.expense) _buildExpenseCategorySelector(),

              // Amount Field
              TextFormField(
                controller: _amountController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: Icon(Icons.payments, color: CustomTheme.primaryColor),
                  hintText: '0.00',
                  filled: true,
                  fillColor: CustomTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.accentColor),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: Icon(Icons.description, color: CustomTheme.primaryColor),
                  hintText: 'Enter description',
                  filled: true,
                  fillColor: CustomTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.primaryColor.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomTheme.accentColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final amount = double.parse(_amountController.text);
                      final financeTracker = Provider.of<FinanceTracker>(
                        context,
                        listen: false,
                      );

                      if (type == TransactionType.expense) {
                        final budget = financeTracker.budgetRule!.getCategoryBudget(_selectedExpenseCategory);
                        final spent = financeTracker.getTotalExpensesByCategory(_selectedExpenseCategory);
                        final available = budget - spent;

                        if (amount > available) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(Icons.warning, color: CustomTheme.errorColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Budget Exceeded',
                                    style: TextStyle(color: CustomTheme.errorColor),
                                  ),
                                ],
                              ),
                              content: Text(
                                'You cannot spend JD ${amount.toStringAsFixed(2)} in ${financeTracker.budgetRule!.getCategoryName(_selectedExpenseCategory)}.\n'
                                    'Available: JD ${available.toStringAsFixed(2)}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                      }

                      final transaction = Transaction(
                        type: type,
                        category: _selectedCategory,
                        amount: amount,
                        description: _descriptionController.text,
                        expenseCategory: type == TransactionType.expense
                            ? _selectedExpenseCategory
                            : null,
                      );

                      final result = financeTracker.addTransaction(transaction);

                      if (result.success) {
                        if (result.showAlert) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    result.alertMessage!.startsWith('Warning')
                                        ? Icons.warning_amber_rounded
                                        : Icons.info_outline,
                                    color: result.alertMessage!.startsWith('Warning')
                                        ? CustomTheme.errorColor
                                        : CustomTheme.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    result.alertMessage!.startsWith('Warning')
                                        ? 'Budget Warning'
                                        : 'Budget Alert',
                                  ),
                                ],
                              ),
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              type == TransactionType.expense
                                  ? 'Expense added successfully!'
                                  : 'Income added successfully!',
                            ),
                            backgroundColor: CustomTheme.accentColor,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(Icons.error_outline, color: CustomTheme.errorColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Transaction Error',
                                  style: TextStyle(color: CustomTheme.errorColor),
                                ),
                              ],
                            ),
                            content: const Text('Error adding transaction. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.error_outline, color: CustomTheme.errorColor),
                              const SizedBox(width: 8),
                              Text(
                                'Transaction Error',
                                style: TextStyle(color: CustomTheme.errorColor),
                              ),
                            ],
                          ),
                          content: const Text('Error adding transaction. Please try again.'),
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
                },
                icon: Icon(
                  type == TransactionType.expense ? Icons.remove : Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  'Add ${type == TransactionType.expense ? 'Expense' : 'Income'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: type == TransactionType.expense ? CustomTheme.errorColor : CustomTheme.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: CustomTheme.primaryColor,
          title: Text(
            'Add Transaction',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: [
              Tab(
                icon: const Icon(Icons.remove_circle_outline),
                text: 'Expense',
                iconMargin: const EdgeInsets.only(bottom: 4),
              ),
              Tab(
                icon: const Icon(Icons.add_circle_outline),
                text: 'Income',
                iconMargin: const EdgeInsets.only(bottom: 4),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildForm(TransactionType.expense),
            _buildForm(TransactionType.income),
          ],
        ),
      ),
    );
  }
}