import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Use firestore prefix for Firestore references
  static final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static final firestore.CollectionReference usersCollection = _firestore.collection('users');
  static final firestore.CollectionReference budgetsCollection = _firestore.collection('budgets');
  static final firestore.CollectionReference transactionsCollection = _firestore.collection('transactions');

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Get user document reference
  static firestore.DocumentReference getUserDocument() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }
    return usersCollection.doc(currentUserId);
  }

  // Get user budget document reference
  static firestore.DocumentReference getUserBudgetDocument() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }
    return budgetsCollection.doc(currentUserId);
  }

  // Get transactions query for current user
  static firestore.Query getUserTransactionsQuery() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }
    return transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true);
  }
}