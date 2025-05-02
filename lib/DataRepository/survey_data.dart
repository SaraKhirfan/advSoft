import 'package:flutter/material.dart';
import 'package:test_sample/models/survey_model.dart';

class BudgetSurveyRepository {
  // Survey questions
  static List<BudgetSurveyQuestion> getSurveyQuestions() {
    return [
      const BudgetSurveyQuestion(
        question: "How would you describe your current financial situation?",
        options: [
          BudgetSurveyOption(
            text: "I'm struggling to make ends meet",
            scores: {"rule5030": 1, "rule7020": 3, "rule3030": 2},
          ),
          BudgetSurveyOption(
            text: "I'm getting by, but not saving much",
            scores: {"rule5030": 2, "rule7020": 2, "rule3030": 3},
          ),
          BudgetSurveyOption(
            text: "I'm comfortable and able to save regularly",
            scores: {"rule5030": 3, "rule7020": 1, "rule3030": 2},
          ),
          BudgetSurveyOption(
            text: "I have significant disposable income",
            scores: {"rule5030": 2, "rule7020": 1, "rule3030": 3},
          ),
        ],
      ),
      const BudgetSurveyQuestion(
        question: "What is your primary financial goal right now?",
        options: [
          BudgetSurveyOption(
            text: "Paying off debt",
            scores: {"rule5030": 2, "rule7020": 3, "rule3030": 1},
          ),
          BudgetSurveyOption(
            text: "Building an emergency fund",
            scores: {"rule5030": 3, "rule7020": 2, "rule3030": 1},
          ),
          BudgetSurveyOption(
            text: "Saving for a specific goal (house, car, etc.)",
            scores: {"rule5030": 2, "rule7020": 3, "rule3030": 1},
          ),
          BudgetSurveyOption(
            text: "Investing for the future",
            scores: {"rule5030": 2, "rule7020": 1, "rule3030": 3},
          ),
        ],
      ),
      const BudgetSurveyQuestion(
        question: "How much of your income currently goes to essential needs (housing, food, utilities)?",
        options: [
          BudgetSurveyOption(
            text: "Less than 40%",
            scores: {"rule5030": 1, "rule7020": 1, "rule3030": 3},
          ),
          BudgetSurveyOption(
            text: "40-50%",
            scores: {"rule5030": 3, "rule7020": 2, "rule3030": 1},
          ),
          BudgetSurveyOption(
            text: "50-70%",
            scores: {"rule5030": 2, "rule7020": 3, "rule3030": 1},
          ),
          BudgetSurveyOption(
            text: "More than 70%",
            scores: {"rule5030": 1, "rule7020": 3, "rule3030": 1},
          ),
        ],
      ),
      const BudgetSurveyQuestion(
        question: "How would you describe your spending on non-essential items?",
        options: [
          BudgetSurveyOption(
            text: "I rarely spend on wants or luxuries",
            scores: {"rule5030": 1, "rule7020": 3, "rule3030": 2},
          ),
          BudgetSurveyOption(
            text: "I occasionally treat myself",
            scores: {"rule5030": 2, "rule7020": 2, "rule3030": 2},
          ),
          BudgetSurveyOption(
            text: "I regularly spend on entertainment and wants",
            scores: {"rule5030": 3, "rule7020": 1, "rule3030": 2},
          ),
          BudgetSurveyOption(
            text: "I spend a significant amount on lifestyle",
            scores: {"rule5030": 3, "rule7020": 1, "rule3030": 3},
          ),
        ],
      ),
      const BudgetSurveyQuestion(
        question: "How diverse do you want your savings/investment allocation to be?",
        options: [
          BudgetSurveyOption(
            text: "I prefer a simple approach with one savings goal",
            scores: {"rule5030": 2, "rule7020": 3, "rule3030": 1},
          ),
          BudgetSurveyOption(
            text: "I'd like to balance between short and long-term goals",
            scores: {"rule5030": 3, "rule7020": 2, "rule3030": 2},
          ),
          BudgetSurveyOption(
            text: "I want to divide my money across multiple categories",
            scores: {"rule5030": 1, "rule7020": 1, "rule3030": 3},
          ),
          BudgetSurveyOption(
            text: "I'm focused primarily on long-term wealth building",
            scores: {"rule5030": 2, "rule7020": 3, "rule3030": 1},
          ),
        ],
      ),
    ];
  }

  // Budget rules
  static Map<String, BudgetRule> getBudgetRules() {
    return {
      "rule5030": const BudgetRule(
        name: "50/30/20 Rule",
        description: "This balanced approach allocates 50% of your income to needs, 30% to wants, and 20% to savings and debt repayment. It's ideal for those with moderate expenses who want to enjoy life while still saving reasonably.",
        categories: [
          BudgetCategory(
            name: "Needs",
            percentage: 50,
            examples: "Housing, groceries, utilities, healthcare, minimum debt payments, transportation",
            color: Colors.blue,
          ),
          BudgetCategory(
            name: "Wants",
            percentage: 30,
            examples: "Dining out, entertainment, shopping, hobbies, vacations, subscriptions",
            color: Colors.orange,
          ),
          BudgetCategory(
            name: "Savings",
            percentage: 20,
            examples: "Emergency fund, retirement accounts, additional debt payments, other savings goals",
            color: Colors.green,
          ),
        ],
      ),
      "rule7020": const BudgetRule(
        name: "70/20/10 Rule",
        description: "This approach focuses on necessary expenses and debt reduction, with 70% going to expenses, 20% to savings, and 10% to debt or donations. It's well-suited for those with high essential costs or focusing on debt payoff.",
        categories: [
          BudgetCategory(
            name: "Expenses",
            percentage: 70,
            examples: "All living expenses including needs and reasonable wants",
            color: Colors.pink,
          ),
          BudgetCategory(
            name: "Savings",
            percentage: 20,
            examples: "Emergency fund, retirement, short and long-term goals",
            color: Colors.blue,
          ),
          BudgetCategory(
            name: "Debt/Giving",
            percentage: 10,
            examples: "Additional debt payments beyond minimums, charitable giving",
            color: Colors.amber,
          ),
        ],
      ),
      "rule3030": const BudgetRule(
        name: "30/30/30/10 Rule",
        description: "This detailed approach divides your budget into housing (30%), other necessities (30%), financial goals (30%), and wants (10%). It's ideal for those who prefer more specific categories and are focused on long-term financial health.",
        categories: [
          BudgetCategory(
            name: "Housing",
            percentage: 30,
            examples: "Rent/mortgage, utilities, maintenance, property taxes",
            color: Colors.purple,
          ),
          BudgetCategory(
            name: "livingExpenses",
            percentage: 30,
            examples: "Food, transportation, healthcare, childcare, minimum debt payments",
            color: Colors.teal,
          ),
          BudgetCategory(
            name: "Financial Goals",
            percentage: 30,
            examples: "Retirement, emergency fund, other savings, investments, additional debt payments",
            color: Colors.indigo,
          ),
          BudgetCategory(
            name: "Discretionary",
            percentage: 10,
            examples: "Entertainment, dining out, hobbies, vacations, non-essential purchases",
            color: Colors.deepOrange,
          ),
        ],
      ),
    };
  }
}
