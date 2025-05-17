import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for editable fields
  final TextEditingController _balanceController = TextEditingController(
      text: '500');
  final TextEditingController _budgetController = TextEditingController(
      text: '200');
  final TextEditingController _savingsGoalController = TextEditingController(
      text: '2500');
  final TextEditingController _emailController = TextEditingController(
      text: 'sara@example.com');

  // Edit mode toggle
  bool _isEditing = false;
  bool _isLoading = true;
  String _displayName = 'Sara Kh';
  String? _errorMessage;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get user profile from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(
          user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          // Set display name
          _displayName = userData['displayName'] ?? 'Sara Kh';

          // Set email
          _emailController.text = user.email ?? 'sara@example.com';

          // Set financial data
          if (userData.containsKey('financialOverview')) {
            Map<String, dynamic> financialData = userData['financialOverview'];
            _balanceController.text =
                (financialData['accountBalance'] ?? 500).toString();
            _budgetController.text =
                (financialData['monthlyBudget'] ?? 200).toString();
            _savingsGoalController.text =
                (financialData['savingsGoal'] ?? 2500).toString();
          }
        });
      } else {
        // No user document exists yet, create one with default values
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': _displayName,
          'email': user.email,
          'financialOverview': {
            'accountBalance': 500,
            'monthlyBudget': 200,
            'savingsGoal': 2500,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data: $e';
      });
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Parse values
      double balance = double.tryParse(_balanceController.text) ?? 500;
      double budget = double.tryParse(_budgetController.text) ?? 200;
      double savingsGoal = double.tryParse(_savingsGoalController.text) ?? 2500;

      // Update financial data in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'financialOverview': {
          'accountBalance': balance,
          'monthlyBudget': budget,
          'savingsGoal': savingsGoal,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: CustomTheme.primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _budgetController.dispose();
    _savingsGoalController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
              'My Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: CustomTheme.primaryColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
              'My Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: CustomTheme.primaryColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error Loading Profile',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: CustomTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
                _isEditing ? Icons.check : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Save changes
                  _saveProfileChanges();
                }
              });
            },
          ),
        ],
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

            // User Name (Non-editable)
            Text(
              _displayName,
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: CustomTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),

            // Email (Non-editable)
            Text(
              _emailController.text,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Account Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Financial Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                    ),
                    _buildProfileItem(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Account Balance',
                      controller: _balanceController,
                      prefix: 'JD ',
                      isEditing: _isEditing,
                    ),
                    const Divider(height: 24),
                    _buildProfileItem(
                      context,
                      icon: Icons.savings,
                      title: 'Monthly Budget',
                      controller: _budgetController,
                      prefix: 'JD ',
                      isEditing: _isEditing,
                    ),
                    const Divider(height: 24),
                    _buildProfileItem(
                      context,
                      icon: Icons.trending_up,
                      title: 'Savings Goal',
                      controller: _savingsGoalController,
                      prefix: 'JD ',
                      isEditing: _isEditing,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account Management Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Account Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                    ),
                    // Delete Account Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      title: const Text('Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: const Text(
                          'Permanently remove your account and data'),
                      trailing: const Icon(
                          Icons.arrow_forward_ios, size: 16, color: Colors.red),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        _showDeleteAccountDialog(context);
                      },
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
    required TextEditingController controller,
    required String prefix,
    required bool isEditing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: CustomTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              isEditing
                  ? TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  prefixText: prefix,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              )
                  : Text(
                '$prefix${controller.text}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Warning: This action cannot be undone. All your data will be permanently deleted.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Password for verification
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                            helperText: 'Enter your password to confirm account deletion',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isLoading ? null : () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: isLoading ? null : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    // Get current user
                                    final user = _auth.currentUser;
                                    if (user == null) {
                                      throw Exception('User not found');
                                    }

                                    // Create credential for re-authentication
                                    AuthCredential credential = EmailAuthProvider
                                        .credential(
                                      email: user.email!,
                                      password: passwordController.text,
                                    );

                                    // Re-authenticate user
                                    await user.reauthenticateWithCredential(
                                        credential);

                                    // Delete user data from Firestore
                                    await _firestore.collection('users').doc(
                                        user.uid).delete();

                                    // Delete transactions, budgets, and tasks if they exist
                                    await _deleteUserData(user.uid);

                                    // Delete user account from Firebase Auth
                                    await user.delete();

                                    // Navigate to login page
                                    if (context.mounted) {
                                      Navigator
                                          .of(context)
                                          .pushNamedAndRemoveUntil(
                                          '/login', (route) => false);
                                    }
                                  } catch (e) {
                                    // Handle specific Firebase errors
                                    String errorMessage = 'Failed to delete account';

                                    if (e.toString().contains(
                                        'wrong-password')) {
                                      errorMessage = 'Incorrect password';
                                    } else if (e.toString().contains(
                                        'requires-recent-login')) {
                                      errorMessage =
                                      'Please log out and log back in before deleting your account';
                                    }

                                    if (context.mounted) {
                                      ScaffoldMessenger
                                          .of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(errorMessage),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                disabledBackgroundColor: Colors.red.withOpacity(
                                    0.5),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text('Delete Account'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

// Helper method to delete all user data
  Future<void> _deleteUserData(String userId) async {
    try {
      // Delete transactions
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in transactionsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete budget
      await _firestore.collection('budgets').doc(userId).delete();

      // Delete tasks
      final tasksQuery = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in tasksQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }
}