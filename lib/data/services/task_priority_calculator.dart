import '../models/task.dart';

class TaskPriorityCalculator {
  static double calculateDeadlineScore(DateTime deadline) {
    final now = DateTime.now();
    final remainingTime = deadline.difference(now);

    if (remainingTime.isNegative) {
      return 100;
    }

    final remainingDays = remainingTime.inHours / 24;

    if (remainingDays > 7) {
      return 20;
    } else if (remainingDays >= 4) {
      return 40;
    } else if (remainingDays >= 2) {
      return 60;
    } else if (remainingDays >= 1) {
      return 80;
    } else {
      return 95;
    }
  }

  static double calculateUserPriorityScore(String priority) {
    switch (priority) {
      case 'High':
        return 100;
      case 'Medium':
        return 60;
      case 'Low':
        return 30;
      default:
        return 60;
    }
  }

  static double calculateDifficultyScore(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 30;
      case 'Medium':
        return 60;
      case 'Hard':
        return 100;
      default:
        return 60;
    }
  }

  static double calculateDurationScore(
      Task task,
      List<Task> activeTasks,
      ) {
    if (activeTasks.isEmpty) {
      return 0;
    }

    double longestDuration = 0;

    for (final activeTask in activeTasks) {
      final durationInHours =
      _convertToHours(
        activeTask.duration,
        activeTask.durationUnit,
      );

      if (durationInHours > longestDuration) {
        longestDuration = durationInHours;
      }
    }

    final taskDurationInHours =
    _convertToHours(
      task.duration,
      task.durationUnit,
    );

    if (longestDuration == 0) {
      return 0;
    }

    return (taskDurationInHours / longestDuration) * 100;
  }

  static double calculateTimePressureScore(Task task) {
    final now = DateTime.now();

    final availableTime =
    task.deadline.difference(now);

    if (availableTime.inSeconds <= 0) {
      return 100;
    }

    final availableTimeInHours =
        availableTime.inMinutes / 60;

    final taskDurationInHours =
    _convertToHours(
      task.duration,
      task.durationUnit,
    );

    final requiredTimeRatio =
        taskDurationInHours / availableTimeInHours;

    if (requiredTimeRatio < 0.10) {
      return 10;
    } else if (requiredTimeRatio < 0.25) {
      return 30;
    } else if (requiredTimeRatio < 0.50) {
      return 50;
    } else if (requiredTimeRatio < 0.75) {
      return 70;
    } else if (requiredTimeRatio < 1.00) {
      return 90;
    } else {
      return 100;
    }
  }

  static double calculatePriorityScore(
      Task task,
      List<Task> activeTasks,
      ) {
    final deadlineScore =
    calculateDeadlineScore(task.deadline);

    final userPriorityScore =
    calculateUserPriorityScore(task.priority);

    final difficultyScore =
    calculateDifficultyScore(task.difficulty);

    final durationScore =
    calculateDurationScore(
      task,
      activeTasks,
    );

    final timePressureScore =
    calculateTimePressureScore(task);

    final finalScore =
        (deadlineScore * 0.40) +
            (userPriorityScore * 0.30) +
            (difficultyScore * 0.15) +
            (durationScore * 0.10) +
            (timePressureScore * 0.05);

    return finalScore;
  }

  static double _convertToHours(
      double duration,
      String unit,
      ) {
    switch (unit) {
      case 'Minutes':
        return duration / 60;

      case 'Hours':
        return duration;

      case 'Days':
        return duration * 24;

      default:
        return duration;
    }
  }
}