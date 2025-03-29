import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        },
      ),
    );
  }
}
