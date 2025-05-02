import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== MODELS ====================

// Budget Survey Question Model
class BudgetSurveyQuestion {
  final String question;
  final List<BudgetSurveyOption> options;

  const BudgetSurveyQuestion({
    required this.question,
    required this.options,
  });
}

// Budget Survey Option Model
class BudgetSurveyOption {
  final String text;
  final Map<String, int> scores;

  const BudgetSurveyOption({
    required this.text,
    required this.scores,
  });
}

// Budget Rule Model
class BudgetRule {
  final String name;
  final String description;
  final List<BudgetCategory> categories;

  const BudgetRule({
    required this.name,
    required this.description,
    required this.categories,
  });
}

// Budget Category Model
class BudgetCategory {
  final String name;
  final int percentage;
  final String examples;
  final Color color;

  const BudgetCategory({
    required this.name,
    required this.percentage,
    required this.examples,
    required this.color,
  });
}
