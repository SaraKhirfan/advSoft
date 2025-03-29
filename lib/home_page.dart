import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_sample/MyTasks.dart';
import 'package:test_sample/Notes_Section.dart';
import 'package:test_sample/Profile.dart';
import 'finance_tracker.dart';
import 'transaction_card.dart';
import 'transaction_form.dart';
import 'custom_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showSetBudgetDialog(BuildContext context) {
    final TextEditingController budgetController = TextEditingController();
    BudgetRuleType selectedRule = BudgetRuleType.rule_503020;

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
                      children: const [
                        Icon(Icons.account_balance_wallet, color: CustomTheme.primaryColor),
                        SizedBox(width: 8),
                        Text('Set Your Budget'),
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
                        prefixIcon: Icon(Icons.rule),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: BudgetRuleType.rule_503020,
                          child: Row(
                            children: const [
                              Icon(Icons.pie_chart, color: CustomTheme.primaryColor),
                              SizedBox(width: 8),
                              Text('50/30/20 Rule'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: BudgetRuleType.rule_702010,
                          child: Row(
                            children: const [
                              Icon(Icons.pie_chart, color: CustomTheme.primaryLightColor),
                              SizedBox(width: 8),
                              Text('70/20/10 Rule'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: BudgetRuleType.rule_303010,
                          child: Row(
                            children: const [
                              Icon(Icons.pie_chart, color: CustomTheme.accentColor),
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
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('• 50% for needs (essential expenses)',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 30% for wants (discretionary spending)',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 20% for savings & investments',
                                      style: TextStyle(fontSize: 14)),
                                ],
                              );
                            case BudgetRuleType.rule_702010:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('• 70% for living expenses',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 20% for savings & wealth building',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 10% for debt repayment or charity',
                                      style: TextStyle(fontSize: 14)),
                                ],
                              );
                            case BudgetRuleType.rule_303010:
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('• 30% for housing',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 30% for living expenses',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 30% for financial goals',
                                      style: TextStyle(fontSize: 14)),
                                  Text('• 10% for discretionary spending',
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
                        prefixIcon: Icon(Icons.account_balance_wallet),
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
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final budget = double.tryParse(budgetController.text);
                            if (budget != null && budget > 0) {
                              Provider.of<FinanceTracker>(context, listen: false)
                                  .setInitialBudget(budget, selectedRule);
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Set Budget'),
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

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
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
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showSetBudgetDialog(context),
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Add Budget'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomTheme.backgroundColor,
                                    foregroundColor: CustomTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Text(
                                'JD ${tracker.balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _showSetBudgetDialog(context),
                                icon: const Icon(Icons.refresh, color: Colors.white70),
                                label: const Text(
                                  'Reset Budget',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer<FinanceTracker>(
                        builder: (context, tracker, child) {
                          if (tracker.budgetRule == null) {
                            return const SizedBox.shrink();
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSummaryCard(
                                  context,
                                  'Income',
                                  tracker.totalIncome,
                                  Icons.arrow_upward,
                                  CustomTheme.accentColor,
                                ),
                                const SizedBox(width: 8),
                                _buildSummaryCard(
                                  context,
                                  'Expense',
                                  tracker.totalExpense,
                                  Icons.arrow_downward,
                                  CustomTheme.errorColor,
                                ),
                              ],
                            ),
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
          Consumer<FinanceTracker>(
            builder: (context, tracker, child) {
              if (tracker.budgetRule != null) {
                final categories = <MapEntry<ExpenseCategory, Color>>[];
                String ruleText = '';

                switch (tracker.budgetRule!.type) {
                  case BudgetRuleType.rule_503020:
                    categories.addAll([
                      MapEntry(ExpenseCategory.needs, CustomTheme.primaryColor),
                      MapEntry(ExpenseCategory.wants, CustomTheme.primaryLightColor),
                      MapEntry(ExpenseCategory.savings, CustomTheme.accentColor),
                    ]);
                    ruleText = '50/30/20 Rule';
                    break;
                  case BudgetRuleType.rule_702010:
                    categories.addAll([
                      MapEntry(ExpenseCategory.living, CustomTheme.primaryColor),
                      MapEntry(ExpenseCategory.savingsWealth, CustomTheme.primaryLightColor),
                      MapEntry(ExpenseCategory.debtCharity, CustomTheme.accentColor),
                    ]);
                    ruleText = '70/20/10 Rule';
                    break;
                  case BudgetRuleType.rule_303010:
                    categories.addAll([
                      MapEntry(ExpenseCategory.housing, CustomTheme.primaryColor),
                      MapEntry(ExpenseCategory.livingExpenses, CustomTheme.primaryLightColor),
                      MapEntry(ExpenseCategory.financialGoals, CustomTheme.accentColor),
                      MapEntry(ExpenseCategory.discretionary, CustomTheme.primaryColor.withOpacity(0.7)),
                    ]);
                    ruleText = '30/30/30/10 Rule';
                    break;
                }

                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Budget Breakdown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CustomTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ruleText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CustomTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...categories.map((entry) {
                          final category = entry.key;
                          final color = entry.value;
                          final totalExpenses = tracker.getTotalExpensesByCategory(category);
                          final budget = tracker.budgetRule!.getCategoryBudget(category);
                          final rulePercentage = (tracker.budgetRule!.getCategoryPercentage(category) * 100).toStringAsFixed(0);
                          final spentPercentage = (totalExpenses / budget * 100).toStringAsFixed(1);

                          return Column(
                            children: [
                              _buildBudgetProgressBar(
                                '${tracker.budgetRule!.getCategoryName(category)} ($rulePercentage% Rule)',
                                totalExpenses,
                                budget,
                                color,
                                showAvailable: true,
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          // Transactions List Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 60.0,
              maxHeight: 60.0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Transactions List
          Consumer<FinanceTracker>(
            builder: (context, tracker, child) {
              if (tracker.transactions.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first transaction using the + button',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final transaction = tracker.transactions[index];
                      return TransactionCard(transaction: transaction);
                    },
                    childCount: tracker.transactions.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const TransactionForm(),
          );
        },
        backgroundColor: CustomTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context,
      String title,
      double amount,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'JD ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgressBar(
      String label,
      double spentAmount,
      double maxAmount,
      Color color, {
        bool showAvailable = false,
      }) {
    final bool isExceeded = spentAmount > maxAmount;
    final double percentage = isExceeded ? 1.0 : (spentAmount / maxAmount);
    final double available = maxAmount - spentAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isExceeded ? CustomTheme.errorColor : Colors.black,
                fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Spent: JD ${spentAmount.toStringAsFixed(2)} / Budget: JD ${maxAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: isExceeded ? CustomTheme.errorColor : Colors.grey[600],
                fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (showAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isExceeded
                      ? 'Exceeded by: JD ${(spentAmount - maxAmount).toStringAsFixed(2)}'
                      : 'Available: JD ${available.toStringAsFixed(2)} (${((available/maxAmount) * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isExceeded ? CustomTheme.errorColor : color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isExceeded ? CustomTheme.errorColor.withOpacity(0.1) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: isExceeded ? 1.0 : percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isExceeded ? CustomTheme.errorColor : color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Finance Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.task_rounded,
            title: 'To - Do',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyTasks()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.note_alt_rounded,
            title: 'Notes',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotesSection()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history_rounded,
            title: 'History',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // Add your logout logic here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildDrawerItem(
    BuildContext context, {
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
  return ListTile(
    leading: Icon(icon, color: CustomTheme.primaryColor),
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        color: CustomTheme.primaryColor,
      ),
    ),
    onTap: onTap,
  );
}
