import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class DBService {
  final CollectionReference _tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  /// Get all tasks ordered by date
  Future<List<Task>> getTasks() async {
    final snapshot = await _tasksRef.orderBy('dateTime').get();
    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  /// 🔥 Real-time stream for live UI updates
  Stream<List<Task>> streamTasks() {
    return _tasksRef.orderBy('dateTime').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  /// Add task and update the task.id with Firestore generated id
  Future<void> addTask(Task task) async {
    final docRef = await _tasksRef.add(task.toMap());
    task.id = docRef.id; // important for further updates/deletes
  }

  /// Update a task by id
  Future<void> updateTask(Task task) async {
    if (task.id.isEmpty) return;
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  /// Delete a task by id
  Future<void> deleteTask(String id) async {
    if (id.isEmpty) return;
    await _tasksRef.doc(id).delete();
  }
}
      