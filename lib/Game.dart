import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'custom_theme.dart';

// ==================== MODELS ====================

// Models for the quiz
class FinancialQuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuestionDifficulty difficulty;
  final QuestionCategory category;

  const FinancialQuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
    required this.category,
  });
}

enum QuestionDifficulty {
  easy,
  medium,
  hard,
}

enum QuestionCategory {
  basicConcepts,
  budgeting,
  saving,
  investing,
  debt,
  taxes,
  retirement,
  insurance,
}

// Achievement badge model
class AchievementBadge {
  final String name;
  final String description;
  final IconData icon; // Using IconData instead of paths for simplicity
  final QuestionCategory category;
  final int requiredCorrectAnswers;
  bool isUnlocked;

  AchievementBadge({
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.requiredCorrectAnswers,
    this.isUnlocked = false,
  });
}

// User quiz progress
class QuizProgress {
  int totalQuestionsAnswered = 0;
  int correctAnswers = 0;
  int coinsEarned = 0;
  Map<QuestionCategory, int> categoryCorrectAnswers = {
    for (var category in QuestionCategory.values) category: 0,
  };
  List<AchievementBadge> unlockedBadges = [];

  void updateProgress({
    required bool isCorrect,
    required QuestionCategory category,
    required List<AchievementBadge> allBadges,
  }) {
    totalQuestionsAnswered++;

    if (isCorrect) {
      correctAnswers++;
      coinsEarned += 10; // Base reward for correct answer
      categoryCorrectAnswers[category] = (categoryCorrectAnswers[category] ?? 0) + 1;

      // Check for new badges
      for (var badge in allBadges) {
        if (!badge.isUnlocked &&
            badge.category == category &&
            (categoryCorrectAnswers[category] ?? 0) >= badge.requiredCorrectAnswers) {
          badge.isUnlocked = true;
          unlockedBadges.add(badge);
          coinsEarned += 50; // Bonus for unlocking a badge
        }
      }
    }
  }
}

// ==================== DATA REPOSITORY ====================

class QuizRepository {
  // Sample questions sorted by category and difficulty
  static List<FinancialQuizQuestion> getAllQuestions() {
    return [
      // Basic Concepts - Easy
      FinancialQuizQuestion(
        question: "What is interest?",
        options: [
          "Money you pay to borrow someone else's money",
          "Money you earn for lending your money to others",
          "Both of the above",
          "None of the above"
        ],
        correctAnswerIndex: 2,
        explanation: "Interest can be paid or earned, depending on whether you're borrowing money (like with a loan) or lending money (like with a savings account).",
        difficulty: QuestionDifficulty.easy,
        category: QuestionCategory.basicConcepts,
      ),

      // Basic Concepts - Medium
      FinancialQuizQuestion(
        question: "What is compound interest?",
        options: [
          "Interest calculated only on the initial principal",
          "Interest calculated on both the initial principal and accumulated interest",
          "Interest that is compounded daily",
          "Interest paid at a fixed rate"
        ],
        correctAnswerIndex: 1,
        explanation: "Compound interest is calculated on both the initial principal and the accumulated interest, causing your money to grow faster over time compared to simple interest.",
        difficulty: QuestionDifficulty.medium,
        category: QuestionCategory.basicConcepts,
      ),

      // Basic Concepts - Hard
      FinancialQuizQuestion(
        question: "Which of the following is NOT a factor in calculating compound interest?",
        options: [
          "Principal amount",
          "Interest rate",
          "Credit score",
          "Time period"
        ],
        correctAnswerIndex: 2,
        explanation: "Credit score affects your ability to get loans and the interest rate you might receive, but it's not a factor in the actual compound interest calculation formula.",
        difficulty: QuestionDifficulty.hard,
        category: QuestionCategory.basicConcepts,
      ),

      // Budgeting - Easy
      FinancialQuizQuestion(
        question: "What is the 50/30/20 budgeting rule?",
        options: [
          "Spend 50% on needs, 30% on wants, and 20% on savings",
          "Save 50%, invest 30%, and spend 20%",
          "Pay 50% of your debt, save 30%, and live on 20%",
          "Invest 50%, save 30%, and spend 20%"
        ],
        correctAnswerIndex: 0,
        explanation: "The 50/30/20 rule suggests allocating 50% of your income to needs (housing, food, etc.), 30% to wants (entertainment, dining out), and 20% to savings and debt repayment.",
        difficulty: QuestionDifficulty.easy,
        category: QuestionCategory.budgeting,
      ),

      // Budgeting - Medium
      FinancialQuizQuestion(
        question: "What is a zero-based budget?",
        options: [
          "A budget where you spend zero dollars on non-essential items",
          "A budget where you account for every dollar of income until you have zero dollars left to budget",
          "A budget where you save zero dollars",
          "A budget where you start from zero every month"
        ],
        correctAnswerIndex: 1,
        explanation: "In a zero-based budget, you allocate every dollar of your income to specific categories (spending, saving, investing, etc.) until you have zero dollars left to budget - 'giving every dollar a job'.",
        difficulty: QuestionDifficulty.medium,
        category: QuestionCategory.budgeting,
      ),

      // Budgeting - Hard
      FinancialQuizQuestion(
        question: "In budgeting, what is the 'envelope system'?",
        options: [
          "A digital budgeting app that separates spending into virtual envelopes",
          "A method where you mail bill payments in envelopes",
          "A cash-based budgeting system where you place cash for different budget categories in separate envelopes",
          "A system where you keep receipts in envelopes for tax purposes"
        ],
        correctAnswerIndex: 2,
        explanation: "The envelope system is a cash-based budgeting method where you physically place cash in different envelopes labeled with spending categories. When an envelope is empty, you've reached your spending limit for that category.",
        difficulty: QuestionDifficulty.hard,
        category: QuestionCategory.budgeting,
      ),

      // Saving - Easy
      FinancialQuizQuestion(
        question: "What is an emergency fund?",
        options: [
          "Money set aside for retirement",
          "Money saved for vacation",
          "Money available for unexpected expenses",
          "Money invested in stocks"
        ],
        correctAnswerIndex: 2,
        explanation: "An emergency fund is money saved specifically for unexpected expenses or financial emergencies, such as medical bills, car repairs, or job loss.",
        difficulty: QuestionDifficulty.easy,
        category: QuestionCategory.saving,
      ),

      // Saving - Medium
      FinancialQuizQuestion(
        question: "How much should typically be in an emergency fund?",
        options: [
          "1 month of expenses",
          "3-6 months of expenses",
          "1 year of expenses",
          "As much as possible"
        ],
        correctAnswerIndex: 1,
        explanation: "Financial experts generally recommend keeping 3-6 months of living expenses in an emergency fund. This provides a reasonable cushion for most emergencies without keeping too much money in low-yielding accounts.",
        difficulty: QuestionDifficulty.medium,
        category: QuestionCategory.saving,
      ),

      // Add other questions as needed...
    ];
  }

  // Achievement badges
  static List<AchievementBadge> getAllBadges() {
    return [
      AchievementBadge(
        name: "Finance Rookie",
        description: "Answer 3 basic concept questions correctly",
        icon: Icons.emoji_events,
        category: QuestionCategory.basicConcepts,
        requiredCorrectAnswers: 3,
      ),
      AchievementBadge(
        name: "Budget Master",
        description: "Answer 3 budgeting questions correctly",
        icon: Icons.account_balance_wallet,
        category: QuestionCategory.budgeting,
        requiredCorrectAnswers: 3,
      ),
      // Add other badges as needed...
    ];
  }

  // Get filtered questions by difficulty
  static List<FinancialQuizQuestion> getQuestionsByDifficulty(QuestionDifficulty difficulty) {
    return getAllQuestions().where((q) => q.difficulty == difficulty).toList();
  }

  // Get filtered questions by category
  static List<FinancialQuizQuestion> getQuestionsByCategory(QuestionCategory category) {
    return getAllQuestions().where((q) => q.category == category).toList();
  }
}

// ==================== ANSWER ANIMATION WIDGETS ====================

class CorrectAnswerAnimation extends StatefulWidget {
  final Widget child;

  const CorrectAnswerAnimation({Key? key, required this.child}) : super(key: key);

  @override
  _CorrectAnswerAnimationState createState() => _CorrectAnswerAnimationState();
}

class _CorrectAnswerAnimationState extends State<CorrectAnswerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Trigger vibration feedback
    HapticFeedback.lightImpact();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
        AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class WrongAnswerAnimation extends StatefulWidget {
  final Widget child;

  const WrongAnswerAnimation({Key? key, required this.child}) : super(key: key);

  @override
  _WrongAnswerAnimationState createState() => _WrongAnswerAnimationState();
}

class _WrongAnswerAnimationState extends State<WrongAnswerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _shakeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Trigger vibration feedback
    HapticFeedback.mediumImpact();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: Offset(0.03, 0.0)),
        weight: 16.7,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.03, 0.0), end: Offset(-0.03, 0.0)),
        weight: 16.7,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(-0.03, 0.0), end: Offset(0.03, 0.0)),
        weight: 16.7,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.03, 0.0), end: Offset(-0.03, 0.0)),
        weight: 16.7,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(-0.03, 0.0), end: Offset(0.03, 0.0)),
        weight: 16.7,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.03, 0.0), end: Offset.zero),
        weight: 16.7,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SlideTransition(
          position: _shakeAnimation,
          child: widget.child,
        ),
        AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 60,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==================== CONFETTI ANIMATION ====================

class ConfettiParticle {
  late Offset position;
  late Color color;
  late double size;
  late double speed;
  late double angle;
  late double spin;
  late double spinSpeed;

  ConfettiParticle({required Size canvasSize}) {
    final random = Random();
    position = Offset(
      random.nextDouble() * canvasSize.width,
      random.nextDouble() * canvasSize.height / 2 - canvasSize.height / 2,
    );

    // Use themed colors
    final colors = [
      CustomTheme.primaryColor,
      CustomTheme.primaryLightColor,
      CustomTheme.accentColor,
      Colors.green,
      Colors.amber,
    ];

    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 10 + 5;
    speed = random.nextDouble() * 5 + 1;
    angle = random.nextDouble() * pi * 2;
    spin = random.nextDouble() * pi * 2;
    spinSpeed = random.nextDouble() * 0.2 - 0.1;
  }

  void update() {
    position = Offset(
      position.dx + sin(angle) * speed / 3,
      position.dy + speed,
    );
    spin += spinSpeed;
  }

  void draw(Canvas canvas) {
    final paint = Paint()..color = color;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(spin);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size,
      height: size,
    );

    canvas.drawRect(rect, paint);
    canvas.restore();
  }
}

class ConfettiWidget extends StatefulWidget {
  final Widget child;
  final bool showConfetti;

  const ConfettiWidget({
    Key? key,
    required this.child,
    required this.showConfetti,
  }) : super(key: key);

  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _particles = [];

    _controller.addListener(() {
      for (final particle in _particles) {
        particle.update();
      }
    });

    if (widget.showConfetti) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    setState(() {
      _particles = List.generate(
        100,
            (_) => ConfettiParticle(canvasSize: Size(MediaQuery.of(context).size.width, 400)),
      );
    });

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showConfetti)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(_particles),
                child: Container(),
              );
            },
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

// ==================== QUIZ GAME SCREEN ====================

class FinancialQuizGame extends StatefulWidget {
  final QuestionDifficulty difficulty;
  final QuestionCategory? category;

  const FinancialQuizGame({
    Key? key,
    this.difficulty = QuestionDifficulty.easy,
    this.category,
  }) : super(key: key);

  @override
  _FinancialQuizGameState createState() => _FinancialQuizGameState();
}

class _FinancialQuizGameState extends State<FinancialQuizGame> {
  late List<FinancialQuizQuestion> _questions;
  late QuizProgress _progress;
  late List<AchievementBadge> _allBadges;

  int _currentQuestionIndex = 0;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  bool _showExplanation = false;
  bool _isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    // Get appropriate questions based on difficulty and optional category
    if (widget.category != null) {
      _questions = QuizRepository.getQuestionsByCategory(widget.category!)
          .where((q) => q.difficulty == widget.difficulty)
          .toList();
    } else {
      _questions = QuizRepository.getQuestionsByDifficulty(widget.difficulty);
    }

    // Shuffle questions for variety
    _questions.shuffle();

    // Limit to 10 questions per session
    if (_questions.length > 10) {
      _questions = _questions.sublist(0, 10);
    }

    _progress = QuizProgress();
    _allBadges = QuizRepository.getAllBadges();
  }

  void _checkAnswer(int selectedIndex) {
    if (_hasAnswered) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;

    setState(() {
      _hasAnswered = true;
      _selectedAnswerIndex = selectedIndex;
      _showExplanation = true;
      _isCorrectAnswer = isCorrect;

      // Update progress
      _progress.updateProgress(
        isCorrect: isCorrect,
        category: currentQuestion.category,
        allBadges: _allBadges,
      );
    });

    // Play sound effect
    if (isCorrect) {
      // Success sound
      HapticFeedback.lightImpact();
    } else {
      // Error sound
      HapticFeedback.vibrate();
    }

    // Show badge notification if new badge unlocked
    if (_progress.unlockedBadges.isNotEmpty) {
      final latestBadge = _progress.unlockedBadges.last;

      // Only show if it was just unlocked in this question
      if (_progress.unlockedBadges.length > 0 &&
          _progress.totalQuestionsAnswered == _currentQuestionIndex + 1) {
        _showBadgeUnlockedDialog(latestBadge);
      }
    }

    // Add slight delay before enabling next question button
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          // Just to refresh the UI
        });
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswerIndex = null;
        _showExplanation = false;
        _isCorrectAnswer = false;
      });
    } else {
      // Quiz completed - show results
      _showQuizCompletedDialog();
    }
  }

  void _showBadgeUnlockedDialog(AchievementBadge badge) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: CustomTheme.backgroundColor,
          title: Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 48,
                color: CustomTheme.primaryColor,
              ),
              SizedBox(height: 8),
              Text(
                'New Badge Unlocked!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: CustomTheme.primaryColor.withOpacity(0.2),
                child: Icon(
                  badge.icon,
                  size: 40,
                  color: CustomTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.textColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomTheme.textColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '+50 coins bonus!',
                      style: TextStyle(
                        color: CustomTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Awesome!',
                style: TextStyle(color: CustomTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showQuizCompletedDialog() {
    final accuracy = _progress.correctAnswers / _progress.totalQuestionsAnswered * 100;

    // Define feedback based on score
    String feedbackTitle;
    String feedbackMessage;
    IconData feedbackIcon;
    Color feedbackColor;

    if (accuracy >= 90) {
      feedbackTitle = "Outstanding!";
      feedbackMessage = "You're a financial genius! Keep it up!";
      feedbackIcon = Icons.emoji_events;
      feedbackColor = CustomTheme.primaryColor;
    } else if (accuracy >= 70) {
      feedbackTitle = "Great Job!";
      feedbackMessage = "You have solid financial knowledge. A little more practice and you'll be an expert.";
      feedbackIcon = Icons.thumb_up;
      feedbackColor = CustomTheme.accentColor;
    } else if (accuracy >= 50) {
      feedbackTitle = "Good Effort!";
      feedbackMessage = "You're on the right track. Keep learning and improving your financial knowledge.";
      feedbackIcon = Icons.trending_up;
      feedbackColor = Colors.amber;
    } else {
      feedbackTitle = "Keep Learning!";
      feedbackMessage = "Financial literacy is a journey. Review the questions and try again to improve your score.";
      feedbackIcon = Icons.school;
      feedbackColor = Colors.blue;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConfettiWidget(
            showConfetti: accuracy >= 70,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: feedbackColor.withOpacity(0.2),
                    child: Icon(
                      feedbackIcon,
                      color: feedbackColor,
                      size: 48,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    feedbackTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: feedbackColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    feedbackMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomTheme.textColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Score:',
                              style: TextStyle(
                                fontSize: 18,
                                color: CustomTheme.textColor,
                              ),
                            ),
                            Text(
                              '${_progress.correctAnswers}/${_progress.totalQuestionsAnswered}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: accuracy / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(accuracy),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${accuracy.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getProgressColor(accuracy),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${_progress.coinsEarned} coins earned',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (_progress.unlockedBadges.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Badges Unlocked:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _progress.unlockedBadges
                          .map((badge) => Tooltip(
                        message: badge.name,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: CustomTheme.primaryColor.withOpacity(0.2),
                          child: Icon(
                            badge.icon,
                            color: CustomTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Update user's total coins in app state
                          // This would depend on your app's state management
                          // Provider.of<UserData>(context, listen: false).addCoins(_progress.coinsEarned);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop(); // Return to quiz menu
                        },
                        child: Text(
                          'Back to Menu',
                          style: TextStyle(color: CustomTheme.primaryColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CustomTheme.primaryColor),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Update user's total coins in app state
                          // Provider.of<UserData>(context, listen: false).addCoins(_progress.coinsEarned);

                          Navigator.of(context).pop();
                          // Reset the quiz
                          setState(() {
                            _initializeQuiz();
                            _currentQuestionIndex = 0;
                            _hasAnswered = false;
                            _selectedAnswerIndex = null;
                            _showExplanation = false;
                            _isCorrectAnswer = false;
                          });
                        },
                        child: Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.lightGreen;
    } else if (percentage >= 40) {
      return Colors.amber;
    } else if (percentage >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Financial Quiz'),
          backgroundColor: CustomTheme.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text('No questions available for this selection'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Game', style: TextStyle(color: Colors.white),),
        backgroundColor: CustomTheme.primaryColor,
        elevation: 0,
        actions: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    '${_progress.coinsEarned}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomTheme.primaryColor,
              CustomTheme.backgroundColor,
            ],
            stops: [0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                Row(
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Question card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(currentQuestion.difficulty).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getDifficultyLabel(currentQuestion.difficulty),
                                style: TextStyle(
                                  color: _getDifficultyColor(currentQuestion.difficulty),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getCategoryLabel(currentQuestion.category),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          currentQuestion.question,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Answer options
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedAnswerIndex == index;
                      final isCorrect = index == currentQuestion.correctAnswerIndex;

                      // Determine button color based on answer state
                      Color buttonColor = Colors.white;
                      Color textColor = CustomTheme.textColor;

                      if (_hasAnswered) {
                        if (isCorrect) {
                          buttonColor = Colors.green.shade100;
                          textColor = Colors.green.shade800;
                        } else if (isSelected) {
                          buttonColor = Colors.red.shade100;
                          textColor = Colors.red.shade800;
                        }
                      } else if (isSelected) {
                        buttonColor = CustomTheme.primaryColor.withOpacity(0.1);
                        textColor = CustomTheme.primaryColor;
                      }

                      Widget answerOption = Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _hasAnswered ? null : () => _checkAnswer(index),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _hasAnswered && isCorrect
                                            ? Colors.green
                                            : _hasAnswered && isSelected
                                            ? Colors.red
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      color: _hasAnswered && isCorrect
                                          ? Colors.green
                                          : _hasAnswered && isSelected
                                          ? Colors.red
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: _hasAnswered
                                          ? Icon(
                                        isCorrect ? Icons.check : isSelected ? Icons.close : null,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                          : Text(
                                        String.fromCharCode(65 + index), // A, B, C, D
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: isSelected || (isCorrect && _hasAnswered)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      // Apply animation if answer was just selected
                      if (_hasAnswered && isSelected) {
                        if (isCorrect) {
                          return CorrectAnswerAnimation(child: answerOption);
                        } else {
                          return WrongAnswerAnimation(child: answerOption);
                        }
                      }

                      return answerOption;
                    },
                  ),
                ),

                // Explanation
                if (_showExplanation) ...[
                  Card(
                    color: _isCorrectAnswer ? Colors.green.shade50 : Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isCorrectAnswer ? Icons.check_circle : Icons.lightbulb,
                                color: _isCorrectAnswer ? Colors.green : Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _isCorrectAnswer ? 'Correct!' : 'Explanation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _isCorrectAnswer ? Colors.green : Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            currentQuestion.explanation,
                            style: TextStyle(
                              color: CustomTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Next button
                if (_hasAnswered)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? 'Next Question'
                          : 'See Results',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 'Easy';
      case QuestionDifficulty.medium:
        return 'Medium';
      case QuestionDifficulty.hard:
        return 'Hard';
    }
  }

  Color _getDifficultyColor(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return Colors.green;
      case QuestionDifficulty.medium:
        return Colors.orange;
      case QuestionDifficulty.hard:
        return Colors.red;
    }
  }

  String _getCategoryLabel(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.basicConcepts:
        return 'Basic Concepts';
      case QuestionCategory.budgeting:
        return 'Budgeting';
      case QuestionCategory.saving:
        return 'Saving';
      case QuestionCategory.investing:
        return 'Investing';
      case QuestionCategory.debt:
        return 'Debt Management';
      case QuestionCategory.taxes:
        return 'Taxes';
      case QuestionCategory.retirement:
        return 'Retirement';
      case QuestionCategory.insurance:
        return 'Insurance';
    }
  }
}