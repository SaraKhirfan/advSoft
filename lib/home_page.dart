import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_sample/login_page.dart';
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
      builder: (context) =>
          Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
              ),
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) =>
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    color: CustomTheme.primaryColor),
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
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
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
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
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
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
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
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
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
                                  onPressed: () {
                                    final budget = double.tryParse(
                                        budgetController.text);
                                    if (budget != null && budget > 0) {
                                      Provider.of<FinanceTracker>(
                                          context, listen: false)
                                          .setInitialBudget(
                                          budget, selectedRule);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: CustomTheme.primaryColor,),
                                  label: const Text('Set Budget', style: TextStyle(color: Colors.white),),
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
                decoration: const BoxDecoration(
                  gradient:  LinearGradient(
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
                                  onPressed: () =>
                                      _showSetBudgetDialog(context),
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Add Budget'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomTheme
                                        .backgroundColor,
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
                                'JOD ${tracker.totalBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _showSetBudgetDialog(context),
                                icon: const Icon(
                                    Icons.refresh, color: Colors.white70),
                                label: const Text(
                                  'Reset Budget',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
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
                                  // Fixed: use method instead of property
                                  Icons.arrow_upward,
                                  CustomTheme.accentColor,
                                ),
                                const SizedBox(width: 8),
                                _buildSummaryCard(
                                  context,
                                  'Expense',
                                  tracker.totalExpense,
                                  // Fixed: use method instead of property
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
                      const MapEntry(ExpenseCategory.needs, CustomTheme.primaryColor),
                      const MapEntry(
                          ExpenseCategory.wants, CustomTheme.primaryLightColor),
                      const MapEntry(
                          ExpenseCategory.savings, CustomTheme.accentColor),
                    ]);
                    ruleText = '50/30/20 Rule';
                    break;
                  case BudgetRuleType.rule_702010:
                    categories.addAll([
                      const MapEntry(
                          ExpenseCategory.living, CustomTheme.primaryColor),
                      const MapEntry(ExpenseCategory.savingsWealth,
                          CustomTheme.primaryLightColor),
                      const MapEntry(
                          ExpenseCategory.debtCharity, CustomTheme.accentColor),
                    ]);
                    ruleText = '70/20/10 Rule';
                    break;
                  case BudgetRuleType.rule_303010:
                    categories.addAll([
                      const MapEntry(
                          ExpenseCategory.housing, CustomTheme.primaryColor),
                      const MapEntry(ExpenseCategory.livingExpenses,
                          CustomTheme.primaryLightColor),
                      const MapEntry(ExpenseCategory.financialGoals,
                          CustomTheme.accentColor),
                      MapEntry(ExpenseCategory.discretionary,
                          CustomTheme.primaryColor.withOpacity(0.7)),
                    ]);
                    ruleText = '30/30/30/10 Rule';
                    break;
                }

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget Breakdown',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(
                                ruleText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: CustomTheme.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Budget breakdown cards with improved layout
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index].key;
                            final color = categories[index].value;
                            final name = tracker.budgetRule!.getCategoryName(
                                category);
                            final budget = tracker.budgetRule!
                                .getCategoryBudget(category);
                            final spent = tracker.getTotalExpensesByCategory(
                                category);
                            final available = budget - spent;
                            final percentage = spent / budget;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percentage.isNaN ||
                                          percentage.isInfinite
                                          ? 0
                                          : percentage,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          color),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    const SizedBox(height: 12),
                                    // Fixed overflow by ensuring flexible text sizing
                                    Row(
                                      children: [
                                        // Budget column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                'Budget',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'JOD ${budget.toStringAsFixed(
                                                    2)}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: CustomTheme.textColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Spent column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                'Spent',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'JOD ${spent.toStringAsFixed(
                                                    2)}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: CustomTheme.errorColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Available column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                'Available',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'JOD ${available.toStringAsFixed(
                                                    2)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: available <= 0
                                                      ? CustomTheme.errorColor
                                                      : CustomTheme
                                                      .successColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          // Recent Transactions Header
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Transactions',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Transactions List
          Consumer<FinanceTracker>(
            builder: (context, tracker, child) {
              if (tracker.transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.deepPurple.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first transaction by tapping the + button below',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const TransactionForm(),
          );
        },
        backgroundColor: Colors.deepPurple,
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
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Centered amount text
          Center(
            child: Text(
              'JOD ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: CustomTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/fin-track.png', width: 150),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: const Text('My Profile', style: TextStyle(fontFamily: 'Roboto'),),
              onTap: () {
                Navigator.pushNamed(context, '/Profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_rounded, color: Colors.deepPurple),
              title: const Text('My Tasks'),
              onTap: () {
                Navigator.pushNamed(context, '/MyTasks');
                // Navigate to analytics page
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_paste_search_rounded, color: Colors.deepPurple),
              title: const Text('Resource Center'),
              onTap: () {
                Navigator.pushNamed(context, '/resource');
                // Navigate to analytics page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded, color: Colors.deepPurple),
              title: const Text('History'),
              onTap: () {
                Navigator.pushNamed(context, '/TransHistory');
                // Navigate to analytics page
              },
            ),
            Divider( thickness: 0.3),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.deepPurple),
              title: const Text('Budget Rule Survey'),
              onTap: () {
                Navigator.pushNamed(context, '/Survey');
                // Navigate to analytics page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.deepPurple),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/Settings');
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepPurple),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
                // Navigate to help page
              },
            ),
          ],
        ),
      ),
    );
  }
}