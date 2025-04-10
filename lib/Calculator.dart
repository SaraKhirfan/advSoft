import 'package:flutter/material.dart';
import 'dart:math';

class FinancialCalculator extends StatefulWidget {
  const FinancialCalculator({super.key});

  @override
  State<FinancialCalculator> createState() => _FinancialCalculatorState();
}

class _FinancialCalculatorState extends State<FinancialCalculator> {
  // Simple Loan Calculator
  final _loanAmountController = TextEditingController();
  final _loanYearsController = TextEditingController();
  double _interestRate = 10.0; // Default value
  String _monthlyPayment = "₹0";
  String _totalPayment = "₹0";

  // Simple Savings Calculator
  final _monthlySavingController = TextEditingController();
  final _savingYearsController = TextEditingController();
  double _savingsInterestRate = 5.0; // Default value
  String _totalSavings = "₹0";
  String _interestEarned = "₹0";

  @override
  void dispose() {
    _loanAmountController.dispose();
    _loanYearsController.dispose();
    _monthlySavingController.dispose();
    _savingYearsController.dispose();
    super.dispose();
  }

  void _calculateLoan() {
    if (_loanAmountController.text.isNotEmpty && _loanYearsController.text.isNotEmpty) {
      final principal = double.parse(_loanAmountController.text);
      final years = int.parse(_loanYearsController.text);
      final monthlyRate = _interestRate / 100 / 12;
      final term = years * 12;

      final monthlyPayment = principal * monthlyRate * pow(1 + monthlyRate, term) / (pow(1 + monthlyRate, term) - 1);
      final totalPayment = monthlyPayment * term;

      setState(() {
        _monthlyPayment = "₹${monthlyPayment.toStringAsFixed(2)}";
        _totalPayment = "₹${totalPayment.toStringAsFixed(2)}";
      });
    }
  }

  void _calculateSavings() {
    if (_monthlySavingController.text.isNotEmpty && _savingYearsController.text.isNotEmpty) {
      final monthlySaving = double.parse(_monthlySavingController.text);
      final years = int.parse(_savingYearsController.text);
      final monthlyRate = _savingsInterestRate / 100 / 12;
      final months = years * 12;

      double futureValue = 0;
      for (int i = 0; i < months; i++) {
        futureValue = (futureValue + monthlySaving) * (1 + monthlyRate);
      }

      final totalDeposits = monthlySaving * months;
      final interestEarned = futureValue - totalDeposits;

      setState(() {
        _totalSavings = "₹${futureValue.toStringAsFixed(2)}";
        _interestEarned = "₹${interestEarned.toStringAsFixed(2)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator', style: TextStyle(color: Colors.white),),
          bottom: TabBar(
            labelColor: Colors.white, // Text color when tab is selected
            unselectedLabelColor: Colors.white70, // Text color when tab is not selected
            indicatorColor: Colors.white, // Color of the line under the selected tab
            tabs: [
              Tab(
                icon: Icon(Icons.money,color: Colors.white,),
                text: 'Loan',
              ),
              Tab(
                icon: Icon(Icons.savings, color: Colors.white,),
                text: 'Savings',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLoanCalculator(),
            _buildSavingsCalculator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoCard(
            title: 'About Loan Calculator',
            content: 'Calculate your monthly loan payments based on loan amount, time period, and interest rate. Adjust the slider to set common interest rates.',
          ),
          const SizedBox(height: 24),

          // Loan Amount
          TextField(
            controller: _loanAmountController,
            decoration: const InputDecoration(
              labelText: 'Loan Amount (₹)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money),
              hintText: 'How much money do you need?',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateLoan(),
          ),
          const SizedBox(height: 16),

          // Loan Term
          TextField(
            controller: _loanYearsController,
            decoration: const InputDecoration(
              labelText: 'Loan Term (Years)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
              hintText: 'How many years to repay?',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateLoan(),
          ),
          const SizedBox(height: 16),

          // Interest Rate Slider
          _buildInterestRateSlider(),
          const SizedBox(height: 16),

          // Common Rates
          _buildCommonRatesSection(),
          const SizedBox(height: 32),

          // Results Section
          _buildResultsCard(
            title: 'Your Loan Results',
            results: [
              {'label': 'Monthly Payment:', 'value': _monthlyPayment},
              {'label': 'Total Payment:', 'value': _totalPayment},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoCard(
            title: 'About Savings Calculator',
            content: 'See how your regular monthly savings grow over time. Adjust the slider to try different interest rates typically offered by banks.',
          ),
          const SizedBox(height: 24),

          // Monthly Saving
          TextField(
            controller: _monthlySavingController,
            decoration: const InputDecoration(
              labelText: 'Monthly Saving (₹)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.savings),
              hintText: 'How much can you save each month?',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateSavings(),
          ),
          const SizedBox(height: 16),

          // Savings Term
          TextField(
            controller: _savingYearsController,
            decoration: const InputDecoration(
              labelText: 'Saving Period (Years)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
              hintText: 'How many years will you save?',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateSavings(),
          ),
          const SizedBox(height: 16),

          // Interest Rate Slider for Savings
          _buildSavingsRateSlider(),
          const SizedBox(height: 16),

          // Common Savings Rates
          _buildCommonSavingsRatesSection(),
          const SizedBox(height: 32),

          // Results Section
          _buildResultsCard(
            title: 'Your Savings Results',
            results: [
              {'label': 'Total Savings:', 'value': _totalSavings},
              {'label': 'Interest Earned:', 'value': _interestEarned},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestRateSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Interest Rate:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_interestRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _interestRate,
          min: 5.0,
          max: 20.0,
          divisions: 30,
          label: '${_interestRate.toStringAsFixed(1)}%',
          onChanged: (value) {
            setState(() {
              _interestRate = value;
              _calculateLoan();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSavingsRateSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Interest Rate:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_savingsInterestRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _savingsInterestRate,
          min: 1.0,
          max: 10.0,
          divisions: 18,
          label: '${_savingsInterestRate.toStringAsFixed(1)}%',
          onChanged: (value) {
            setState(() {
              _savingsInterestRate = value;
              _calculateSavings();
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommonRatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Loan Rates:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildRateChip('Home Loan', 8.5),
            _buildRateChip('Car Loan', 9.5),
            _buildRateChip('Personal Loan', 12.0),
            _buildRateChip('Credit Card', 18.0),
          ],
        ),
      ],
    );
  }

  Widget _buildCommonSavingsRatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Savings Rates:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSavingsRateChip('Savings Account', 2.5),
            _buildSavingsRateChip('Fixed Deposit', 5.5),
            _buildSavingsRateChip('Recurring Deposit', 4.5),
            _buildSavingsRateChip('PPF', 7.1),
          ],
        ),
      ],
    );
  }

  Widget _buildRateChip(String label, double rate) {
    return ActionChip(
      avatar: const Icon(Icons.percent, size: 16),
      label: Text('$label: ${rate.toStringAsFixed(1)}%'),
      onPressed: () {
        setState(() {
          _interestRate = rate;
          _calculateLoan();
        });
      },
    );
  }

  Widget _buildSavingsRateChip(String label, double rate) {
    return ActionChip(
      avatar: const Icon(Icons.percent, size: 16),
      label: Text('$label: ${rate.toStringAsFixed(1)}%'),
      onPressed: () {
        setState(() {
          _savingsInterestRate = rate;
          _calculateSavings();
        });
      },
    );
  }

  Widget _buildResultsCard({
    required String title,
    required List<Map<String, String>> results,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...results.map((result) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      result['label']!,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      result['value']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
