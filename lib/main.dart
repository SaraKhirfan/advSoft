import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_sample/Calculator.dart';
import 'package:test_sample/Game.dart';
import 'package:test_sample/MyTasks.dart';
import 'package:test_sample/Profile.dart';
import 'package:test_sample/settings.dart';
import 'finance_tracker.dart';
import 'home_page.dart';
import 'custom_theme.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FinanceTracker(),
      child: MaterialApp(
        title: 'Finance Tracker',
        theme: CustomTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomePage(),
          '/MyTasks':(context) => const MyTasks(),
          '/Profile':(context) => const ProfilePage(),
          '/Settings':(context) => const SettingsPage(),
          '/Calculator':(context)=>const FinancialCalculator(),
          '/Game':(context)=>const FinancialQuizGame(),
        },
      ),
    );
  }
}
