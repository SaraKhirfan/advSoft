import 'package:flutter/material.dart';
import 'package:test_sample/finance_tracker.dart';


class CategoryItem {
  final String name;
  final IconData icon;
  // Add budget category mapping properties
  final ExpenseCategory category50_30_20;     // For 50/30/20 rule
  final ExpenseCategory category70_20_10;     // For 70/20/10 rule
  final ExpenseCategory category30_30_30_10;  // For 30/30/30/10 rule

  CategoryItem({
    required this.name,
    required this.icon,
    required this.category50_30_20,
    required this.category70_20_10,
    required this.category30_30_30_10,
  });
}