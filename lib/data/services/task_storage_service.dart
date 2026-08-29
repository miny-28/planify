import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';

  Future<void> saveTasks(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();

    final tasksJson = tasks.map((task) => task.toJson()).toList();

    await preferences.setString(
      _tasksKey,
      jsonEncode(tasksJson),
    );
  }

  Future<List<Task>> getTasks() async {
    final preferences = await SharedPreferences.getInstance();

    final tasksString = preferences.getString(_tasksKey);

    if (tasksString == null) {
      return [];
    }

    final List<dynamic> tasksJson = jsonDecode(tasksString);

    return tasksJson
        .map((taskJson) => Task.fromJson(taskJson))
        .toList();
  }

  Future<void> addTask(Task task) async {
    final tasks = await getTasks();

    tasks.add(task);

    await saveTasks(tasks);
  }

  Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();

    final index = tasks.indexWhere(
          (task) => task.id == updatedTask.id,
    );

    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();

    tasks.removeWhere(
          (task) => task.id == taskId,
    );

    await saveTasks(tasks);
  }
}