import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'custom_theme.dart';
import 'package:test_sample/models/survey_model.dart';
import 'package:test_sample/DataRepository/survey_data.dart';

class BudgetSurveyScreen extends StatefulWidget {
  const BudgetSurveyScreen({super.key});

  @override
  _BudgetSurveyScreenState createState() => _BudgetSurveyScreenState();
}

class _BudgetSurveyScreenState extends State<BudgetSurveyScreen> {
  final List<BudgetSurveyQuestion> _questions = BudgetSurveyRepository.getSurveyQuestions();
  final Map<String, BudgetRule> _budgetRules = BudgetSurveyRepository.getBudgetRules();

  int _currentQuestionIndex = 0;
  List<int> _selectedOptions = [];
  bool _showResults = false;
  String _recommendedRuleKey = "";

  @override
  void initState() {
    super.initState();
    // Show the welcome popup dialog when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  // Welcome dialog function
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Image.asset('assets/images/fin-track.png', width: 180),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Budget Rule Survey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.primaryColor,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This survey will help you determine which budget rule is most suitable for your financial habits and goals.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Answer a few questions about your finances to get a personalized recommendation for one of these budget rules:',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildRuleListTile('50/30/20 Rule'),
              _buildRuleListTile('70/20/10 Rule'),
              _buildRuleListTile('30/30/30/10 Rule'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Let\'s Begin',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build rule list tiles for the welcome dialog
  Widget _buildRuleListTile(String ruleName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.deepPurple,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            ruleName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _selectOption(int optionIndex) {
    if (_currentQuestionIndex < _questions.length) {
      setState(() {
        if (_currentQuestionIndex >= _selectedOptions.length) {
          _selectedOptions.add(optionIndex);
        } else {
          _selectedOptions[_currentQuestionIndex] = optionIndex;
        }
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1 &&
        _currentQuestionIndex < _selectedOptions.length) {
      setState(() {
        _currentQuestionIndex++;
      });
      // Provide haptic feedback for question transition
      HapticFeedback.lightImpact();
    } else if (_currentQuestionIndex == _questions.length - 1 &&
        _currentQuestionIndex < _selectedOptions.length) {
      _calculateResults();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      // Provide haptic feedback for question transition
      HapticFeedback.lightImpact();
    }
  }

  void _calculateResults() {
    Map<String, int> scores = {
      "rule5030": 0,
      "rule7020": 0,
      "rule3030": 0,
    };

    // Calculate scores for each budget rule based on selected options
    for (int i = 0; i < _selectedOptions.length; i++) {
      int optionIndex = _selectedOptions[i];
      BudgetSurveyOption selectedOption = _questions[i].options[optionIndex];

      selectedOption.scores.forEach((rule, score) {
        scores[rule] = (scores[rule] ?? 0) + score;
      });
    }

    // Find the rule with the highest score
    String highestScoringRule = "rule5030"; // Default
    int highestScore = 0;

    scores.forEach((rule, score) {
      if (score > highestScore) {
        highestScore = score;
        highestScoringRule = rule;
      }
    });

    setState(() {
      _recommendedRuleKey = highestScoringRule;
      _showResults = true;
    });

    // Provide haptic feedback for results
    HapticFeedback.mediumImpact();
  }

  void _restartSurvey() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptions = [];
      _showResults = false;
      _recommendedRuleKey = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultsScreen();
    } else {
      return _buildSurveyScreen();
    }
  }

  Widget _buildSurveyScreen() {
    final BudgetSurveyQuestion currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Rule Survey', style: TextStyle(color: Colors.white),),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex) / _questions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Question and options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(
                      currentQuestion.options.length,
                          (index) => _buildOptionCard(index, currentQuestion.options[index]),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentQuestionIndex < _selectedOptions.length
                        ? _nextQuestion
                        : null,
                    icon: Icon(_currentQuestionIndex < _questions.length - 1
                        ? Icons.arrow_forward
                        : Icons.check_circle),
                    label: Text(_currentQuestionIndex < _questions.length - 1
                        ? 'Next'
                        : 'See Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(int optionIndex, BudgetSurveyOption option) {
    final bool isSelected = _selectedOptions.length > _currentQuestionIndex &&
        _selectedOptions[_currentQuestionIndex] == optionIndex;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? CustomTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          _selectOption(optionIndex);
          // Provide haptic feedback for selection
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio(
                value: optionIndex,
                groupValue: _selectedOptions.length > _currentQuestionIndex
                    ? _selectedOptions[_currentQuestionIndex]
                    : null,
                onChanged: (value) {
                  if (value != null) {
                    _selectOption(value);
                    // Provide haptic feedback for selection
                    HapticFeedback.selectionClick();
                  }
                },
                activeColor: CustomTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: CustomTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final BudgetRule recommendedRule = _budgetRules[_recommendedRuleKey]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Budget Rule', style: TextStyle(color: Colors.white),),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartSurvey,
            tooltip: 'Take Survey Again',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Result Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                     const SizedBox(height: 16),
                      Text(
                        'Recommended Budget Rule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendedRule.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recommendedRule.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Pie Chart Visualization
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Budget Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                     const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: CustomPaint(
                          painter: BudgetPieChartPainter(
                            categories: recommendedRule.categories,
                          ),
                          child: Center(
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration:const  BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: CustomTheme.primaryColor,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                     const SizedBox(height: 20),

                      // Legend
                      ...recommendedRule.categories.map((category) => _buildLegendItem(category)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Detailed Categories
              ...recommendedRule.categories.map((category) => _buildCategoryCard(category)),

             const SizedBox(height: 8),

              TextButton(
                onPressed: _restartSurvey,
                child: const Text('Take Survey Again', style: TextStyle(fontSize: 18),),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BudgetCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${category.name} (${category.percentage}%)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BudgetCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: category.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    color: category.color,
                  ),
                ),
               const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${category.name} (${category.percentage}%)',
                        style:const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: category.percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(category.color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Includes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
           const SizedBox(height: 4),
            Text(
              category.examples,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'needs':
        return Icons.home;
      case 'wants':
        return Icons.shopping_cart;
      case 'savings':
        return Icons.savings;
      case 'expenses':
        return Icons.receipt_long;
      case 'debt/giving':
        return Icons.credit_card;
      case 'housing':
        return Icons.house;
      case 'necessities':
        return Icons.fastfood;
      case 'financial goals':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  }
}

// Custom Pie Chart Painter
class BudgetPieChartPainter extends CustomPainter {
  final List<BudgetCategory> categories;

  BudgetPieChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    double startAngle = -pi / 2; // Start from the top

    for (var category in categories) {
      final double sweepAngle = 2 * pi * category.percentage / 100;

      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = category.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw a smaller white circle in the center for a donut effect
    final Paint centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawCircle(
      center,
      radius * 0.5, // Inner radius is 50% of the outer radius
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}