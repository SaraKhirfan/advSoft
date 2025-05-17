import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_theme.dart';
import 'services/firebase_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _notificationsEnabled = userData['notificationsEnabled'] ?? true;
          });
        }
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }

  Future<void> _updateNotificationPreference(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'notificationsEnabled': value,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _notificationsEnabled = value;
        });
      }
    } catch (e) {
      print('Error updating notification preferences: $e');
      // Revert to previous state if update fails
      setState(() {
        _notificationsEnabled = !value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update notification preference: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: CustomTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildSwitchSettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Receive Reminders to track your expense',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      _updateNotificationPreference(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get answers to your questions',
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: CustomTheme.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
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
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
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
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.deepPurple,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
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
                            color: CustomTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: CustomTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.deepPurple)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
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
                                AuthCredential credential = EmailAuthProvider.credential(
                                  email: user.email!,
                                  password: currentPasswordController.text,
                                );

                                // Re-authenticate user
                                await user.reauthenticateWithCredential(credential);

                                // Update password
                                await user.updatePassword(newPasswordController.text);

                                // Update Firestore record
                                await _firestore.collection('users').doc(user.uid).update({
                                  'passwordUpdatedAt': FieldValue.serverTimestamp(),
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password updated successfully'),
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                  );
                                }
                              } catch (e) {
                                String errorMessage = 'Failed to update password';

                                if (e.toString().contains('wrong-password')) {
                                  errorMessage = 'Current password is incorrect';
                                } else if (e.toString().contains('requires-recent-login')) {
                                  errorMessage = 'Please log out and log back in before changing your password';
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Update Password'),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CustomTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CustomTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'How do I create a new budget?',
                    'Go to Budget Settings from the sidebar menu and set up your initial budget and preferred budget rule.',
                  ),
                  _buildFAQItem(
                    'How do I add transactions?',
                    'Use the + button on the home screen to add income or expenses.',
                  ),
                  _buildFAQItem(
                    'How does the budget rule work?',
                    'Budget rules help allocate your income into different categories based on popular personal finance methods.',
                  ),
                  _buildFAQItem(
                    'Can I export my data?',
                    'This feature is coming soon in a future update.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you need additional help, contact us at:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'support@fintrack.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}