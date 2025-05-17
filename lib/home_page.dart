import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'finance_tracker.dart';
import 'transaction_card.dart';
import 'transaction_form.dart';
import 'custom_theme.dart';
import 'services/firebase_service.dart';
import 'services/budget_service.dart';
import 'services/transaction_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BudgetService _budgetService = BudgetService();
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    if (FirebaseService.currentUserId == null) {
      // Redirect to login
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
      // Load budget data
      final budgetRule = await _budgetService.getBudgetRule();
      if (budgetRule != null && mounted) {
        Provider.of<FinanceTracker>(context, listen: false)
            .setBudgetRule(budgetRule);
      }

      // Load transactions
      final transactions = await _transactionService.getUserTransactions();
      if (mounted) {
        Provider.of<FinanceTracker>(context, listen: false)
            .setTransactions(transactions);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSetBudgetDialog(BuildContext context) {
    final financeTracker = Provider.of<FinanceTracker>(context, listen: false);
    final TextEditingController budgetController = TextEditingController();
    BudgetRuleType selectedRule = BudgetRuleType.rule_503020;

    if (financeTracker.budgetRule != null) {
      // Get the budget amount from the current rule
      final currentRule = financeTracker.budgetRule!;
      // Calculate total budget by adding up category budgets
      double totalAmount = 0;

      // For 50/30/20 rule
      if (currentRule.type == BudgetRuleType.rule_503020) {
        totalAmount = currentRule.getCategoryBudget(ExpenseCategory.needs) +
            currentRule.getCategoryBudget(ExpenseCategory.wants) +
            currentRule.getCategoryBudget(ExpenseCategory.savings);
      }
      // For 70/20/10 rule
      else if (currentRule.type == BudgetRuleType.rule_702010) {
        totalAmount = currentRule.getCategoryBudget(ExpenseCategory.living) +
            currentRule.getCategoryBudget(ExpenseCategory.savingsWealth) +
            currentRule.getCategoryBudget(ExpenseCategory.debtCharity);
      }
      // For 30/30/30/10 rule
      else if (currentRule.type == BudgetRuleType.rule_303010) {
        totalAmount = currentRule.getCategoryBudget(ExpenseCategory.housing) +
            currentRule.getCategoryBudget(ExpenseCategory.livingExpenses) +
            currentRule.getCategoryBudget(ExpenseCategory.financialGoals) +
            currentRule.getCategoryBudget(ExpenseCategory.discretionary);
      }

      budgetController.text = totalAmount.toString();
      selectedRule = currentRule.type;
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: CustomTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(financeTracker.budgetRule != null
                            ? 'Update Your Budget'
                            : 'Set Your Budget'),
                      ],
                    ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select a budget rule and enter your total budget:',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            // Budget Rule Selection
                            DropdownButtonFormField<BudgetRuleType>(
                              value: selectedRule,
                              decoration: const InputDecoration(
                                labelText: 'Budget Rule',
                                prefixIcon: Icon(Icons.rule, color: Colors.deepPurple,),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: BudgetRuleType.rule_503020,
                                  child: Row(
                                    children:  [
                                      Icon(Icons.pie_chart,
                                          color: CustomTheme.primaryColor),
                                      SizedBox(width: 8),
                                      Text('50/30/20 Rule'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: BudgetRuleType.rule_702010,
                                  child: Row(
                                    children:  [
                                      Icon(Icons.pie_chart,
                                          color: CustomTheme.primaryLightColor),
                                      SizedBox(width: 8),
                                      Text('70/20/10 Rule'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: BudgetRuleType.rule_303010,
                                  child: Row(
                                    children:  [
                                      Icon(Icons.pie_chart,
                                          color: CustomTheme.accentColor),
                                      SizedBox(width: 8),
                                      Text('30/30/30/10 Rule'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedRule = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            // Rule Description
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CustomTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Builder(
                                builder: (context) {
                                  switch (selectedRule) {
                                    case BudgetRuleType.rule_503020:
                                      return const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:  [
                                          Text(
                                              '• 50% for needs (essential expenses)',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              '• 30% for wants (discretionary spending)',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              '• 20% for savings & investments',
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      );
                                    case BudgetRuleType.rule_702010:
                                      return const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('• 70% for living expenses',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              '• 20% for savings & wealth building',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              '• 10% for debt repayment or charity',
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      );
                                    case BudgetRuleType.rule_303010:
                                      return const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('• 30% for housing',
                                              style: TextStyle(fontSize: 14)),
                                          Text('• 30% for living expenses',
                                              style: TextStyle(fontSize: 14)),
                                          Text('• 30% for financial goals',
                                              style: TextStyle(fontSize: 14)),
                                          Text(
                                              '• 10% for discretionary spending',
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: budgetController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Total Budget',
                                prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.deepPurple,),
                                hintText: '0.00',
                                helperText: 'Enter your total available budget',
                              ),
                              autofocus: true,
                            ),
                            const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple),),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final budget = double.tryParse(budgetController.text);
                            if (budget != null && budget > 0) {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              try {
                                // Save to Firebase
                                final success = await _budgetService.saveBudgetRule(budget, selectedRule);

                                // Close loading dialog - Important: This is a separate statement
                                if (mounted) Navigator.pop(context);

                                // Then check success separately
                                if (success) {
                                  // Update local state
                                  if (mounted) {
                                    Provider.of<FinanceTracker>(context, listen: false)
                                        .setInitialBudget(budget, selectedRule);
                                  }

                                  // Close budget dialog
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  // Show error message
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to save budget settings')),
                                    );
                                  }
                                }
                              } catch (e) {
                                // Close loading dialog if there's an error
                                if (mounted) {
                                  Navigator.pop(context);
                                }

                                // Show error message
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: CustomTheme.primaryColor,
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            financeTracker.budgetRule != null ? 'Update Budget' : 'Set Budget',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                              ],
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      elevation: 5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CustomTheme.primaryColor,
                  CustomTheme.primaryLightColor,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                child: Image.asset('assets/images/fin_logo.png', width: 160),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
              context, Icons.home, "Home", () => Navigator.pushReplacementNamed(context, "/home")),
          _buildDrawerItem(
              context, Icons.task_alt, "My Tasks", () => Navigator.pushNamed(context, "/MyTasks")),
          _buildDrawerItem(
              context, Icons.person, "Profile", () => Navigator.pushNamed(context, "/Profile")),
          _buildDrawerItem(
              context, Icons.history, "Transaction History", () => Navigator.pushNamed(context, "/TransHistory")),
          _buildDrawerItem(
              context, Icons.info, "Resource Center", () => Navigator.pushNamed(context, "/resource")),
          _buildDrawerItem(
              context, Icons.question_answer_rounded, "Budget Rule Survey", () => Navigator.pushNamed(context, "/Survey")),
          const Divider(),
          _buildDrawerItem(
              context, Icons.settings, "Settings", () => Navigator.pushNamed(context, "/Settings")),
          _buildDrawerItem(context, Icons.exit_to_app, "Logout", () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: CustomTheme.primaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkAuthAndLoadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with Balance and Budget Status
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CustomTheme.primaryColor,
                      CustomTheme.primaryLightColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<FinanceTracker>(
                        builder: (context, tracker, child) {
                          if (tracker.budgetRule == null) {
                            return Column(
                              children: [
                                const Text(
                                  'Set up your budget',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _showSetBudgetDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: CustomTheme.primaryColor,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Set Budget'),
                                ),
                              ],
                            );
                          }

                          final balance = tracker.getCurrentBalance();
                          final formattedBalance =
                              'JOD ${balance.toStringAsFixed(2)}';
                          final income = tracker.getTotalIncome();
                          final expenses = tracker.getTotalExpenses();

                          return Column(
                            children: [
                              Text(
                                formattedBalance,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Income Card
                                  Card(
                                    color: Colors.white.withOpacity(0.2),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Income',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'JOD ${income.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Expenses Card
                                  Card(
                                    color: Colors.white.withOpacity(0.2),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Expenses',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'JOD ${expenses.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (tracker.budgetRule != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Budget Info Card
                                    Card(
                                      color: Colors.white.withOpacity(0.15),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.pie_chart,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              tracker.budgetRule!
                                                  .getDisplayName(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Budget Breakdown
          SliverToBoxAdapter(
            child: Consumer<FinanceTracker>(
              builder: (context, tracker, child) {
                if (tracker.budgetRule == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // In the Budget Breakdown section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  color: CustomTheme.primaryLightColor),
                              SizedBox(width: 8),
                              Text(
                                'Budget Breakdown',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CustomTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                          // Add Reset Budget button here
                          TextButton.icon(
                            onPressed: () => _showSetBudgetDialog(context),
                            icon: const Icon(Icons.refresh, size: 18, color: Colors.deepPurple),
                            label: const Text('Reset Budget', style: TextStyle(color: Colors.deepPurple)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...tracker.budgetRule!.getCategories().map((category) {
                        final percentage = tracker.budgetRule!
                            .getCategoryPercentage(category);
                        final budget = tracker.budgetRule!
                            .getCategoryBudget(category);
                        final spent = tracker.getTotalExpensesByCategory(
                            category);
                        final remaining = budget - spent;
                        final progress = spent / budget;
                        final isOverBudget = remaining < 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tracker.budgetRule!
                                        .getCategoryName(category),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: CustomTheme.textColor,
                                    ),
                                  ),
                                  Text(
                                    '${(percentage * 100).toInt()}% • JOD ${budget.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Progress bar for budget
                              Stack(
                                children: [
                                  // Full bar (background)
                                  Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  // Progress bar (foreground)
                                  Container(
                                    height: 8,
                                    width: MediaQuery.of(context).size.width *
                                        0.75 *
                                        (progress > 1 ? 1 : progress),
                                    decoration: BoxDecoration(
                                      color: isOverBudget
                                          ? Colors.red
                                          : (progress > 0.75
                                          ? Colors.orange
                                          : CustomTheme.primaryColor),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Spent amount and remaining
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Spent: JOD ${spent.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CustomTheme.textColor,
                                    ),
                                  ),
                                  Text(
                                    isOverBudget
                                        ? 'Over by: JOD ${(-remaining).toStringAsFixed(2)}'
                                        : 'Remaining: JOD ${remaining.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOverBudget
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),

          // Recent Transactions
          SliverToBoxAdapter(
            child: Consumer<FinanceTracker>(
              builder: (context, financeTracker, child) {
                final transactions = financeTracker.transactions;
                // Sort transactions by date (newest first)
                final sortedTransactions = [...transactions]
                  ..sort((a, b) => b.date.compareTo(a.date));

                // Take only the first 2 transactions for the home page
                final recentTransactions = sortedTransactions.take(2).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '   Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/TransHistory');
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: CustomTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (transactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No transactions yet. Add one to get started!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: recentTransactions.map((transaction) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TransactionCard(
                              transaction: transaction,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Add Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransactionForm()),
          );
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}