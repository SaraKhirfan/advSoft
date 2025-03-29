import 'package:flutter/material.dart';
import 'custom_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomTheme.primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: CustomTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: CustomTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Name
            Text(
              'Sara Kh',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              'sara@example.com',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const SizedBox(height: 32),

            // Account Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileItem(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Account Balance',
                      value: 'JD 500',
                    ),
                    const Divider(height: 24),
                    _buildProfileItem(
                      context,
                      icon: Icons.savings,
                      title: 'Monthly Budget',
                      value: 'JD 200',
                    ),
                    const Divider(height: 24),
                    _buildProfileItem(
                      context,
                      icon: Icons.trending_up,
                      title: 'Savings Goal',
                      value: 'JD 2500',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: CustomTheme.primaryColor,
          size: 28,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
            Text(
              value,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}