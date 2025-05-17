// user_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final String? userId = FirebaseService.currentUserId;
      if (userId == null) return null;

      final docSnapshot = await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update financial overview
  Future<bool> updateFinancialOverview({
    required double accountBalance,
    required double monthlyBudget,
    required double savingsGoal,
  }) async {
    try {
      final String? userId = FirebaseService.currentUserId;
      if (userId == null) return false;

      await _firestore.collection('users').doc(userId).update({
        'financialOverview.accountBalance': accountBalance,
        'financialOverview.monthlyBudget': monthlyBudget,
        'financialOverview.savingsGoal': savingsGoal,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating financial overview: $e');
      return false;
    }
  }

  // Update email address (requires re-authentication)
  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      await user.updateEmail(newEmail);

      // Update email in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  // Delete user account (requires re-authentication)
  Future<bool> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete the user account
      await user.delete();

      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}