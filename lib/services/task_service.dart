// services/task_service.dart
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'firebase_service.dart';

class TaskService {
  // Collection reference
  final _tasksCollection = firestore.FirebaseFirestore.instance.collection('tasks');

  // Add a new task
  Future<String?> addTask(Map<String, dynamic> task) async {
    if (FirebaseService.currentUserId == null) return null;

    try {
      final docRef = await _tasksCollection.add(task);
      return docRef.id;
    } catch (e) {
      print('Error adding task: $e');
      return null;
    }
  }

  // Get all tasks for current user
  Future<List<Map<String, dynamic>>> getUserTasks() async {
    if (FirebaseService.currentUserId == null) return [];

    try {
      final snapshot = await _tasksCollection
          .where('userId', isEqualTo: FirebaseService.currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add id to the map
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  // Update task
  Future<bool> updateTask(Map<String, dynamic> task) async {
    if (FirebaseService.currentUserId == null) return false;
    final taskId = task['id'];
    if (taskId == null) return false;

    try {
      // Remove id from the task data
      final taskData = Map<String, dynamic>.from(task);
      taskData.remove('id');

      await _tasksCollection.doc(taskId).update(taskData);
      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Toggle task completion status
  Future<bool> toggleTaskCompletion(String taskId, bool currentStatus) async {
    if (FirebaseService.currentUserId == null) return false;

    try {
      await _tasksCollection.doc(taskId).update({
        'isCompleted': !currentStatus
      });
      return true;
    } catch (e) {
      print('Error toggling task completion: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    if (FirebaseService.currentUserId == null) return false;

    try {
      await _tasksCollection.doc(taskId).delete();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }
}