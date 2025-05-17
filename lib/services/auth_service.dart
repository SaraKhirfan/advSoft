import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user information in Firestore
      // Only do this if Firestore is properly set up
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
        });
      } catch (e) {
        print("Firestore error (not critical): $e");
        // We'll continue even if Firestore fails, as the authentication was successful
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth error: ${e.code} - ${e.message}");
      throw e;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth login error: ${e.code} - ${e.message}");
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        try {
          await _firestore.collection('users').doc(user.uid).delete();
        } catch (e) {
          print("Firestore deletion error (not critical): $e");
        }
        // Delete user account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(data);
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

}