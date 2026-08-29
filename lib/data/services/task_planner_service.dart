import '../models/task.dart';
import '../models/available_time.dart';
import 'task_priority_calculator.dart';

class TaskPlannerService {
  List<Task> getActiveTasks(List<Task> tasks) {
    return tasks
        .where((task) => !task.isCompleted)
        .toList();
  }

  List<Task> sortTasksByPriority(List<Task> tasks) {
    final activeTasks = getActiveTasks(tasks);

    activeTasks.sort((a, b) {
      final scoreA =
      TaskPriorityCalculator.calculatePriorityScore(
        a,
        activeTasks,
      );

      final scoreB =
      TaskPriorityCalculator.calculatePriorityScore(
        b,
        activeTasks,
      );

      return scoreB.compareTo(scoreA);
    });

    return activeTasks;
  }

  double getDurationInHours(Task task) {
    if (task.durationUnit == 'minutes') {
      return task.duration / 60;
    }

    if (task.durationUnit == 'days') {
      return task.duration * 24;
    }

    return task.duration;
  }

  Map<String, List<Map<String, dynamic>>> createDailySchedule(
      List<Task> tasks,
      List<AvailableTime> availableTimes,
      ) {
    final sortedTasks = sortTasksByPriority(tasks);

    final schedule =
    <String, List<Map<String, dynamic>>>{};

    for (final time in availableTimes) {
      if (!time.isAvailable) {
        continue;
      }

      schedule.putIfAbsent(
        time.day,
            () => [],
      );
    }

    for (final task in sortedTasks) {
      double remainingDuration =
      getDurationInHours(task);

      for (final time in availableTimes) {
        if (!time.isAvailable) {
          continue;
        }

        if (remainingDuration <= 0) {
          break;
        }

        final availableStart = time.startTime;
        final availableEnd = time.endTime;

        if (availableEnd.isBefore(availableStart) ||
            availableEnd.isAtSameMomentAs(availableStart)) {
          continue;
        }

        if (task.deadline.isBefore(availableStart)) {
          continue;
        }

        schedule.putIfAbsent(
          time.day,
              () => [],
        );

        final daySchedule = schedule[time.day]!;

        DateTime currentStart = availableStart;

        if (daySchedule.isNotEmpty) {
          final lastTask = daySchedule.last;

          final lastEnd =
          lastTask['endTime'] as DateTime;

          if (lastEnd.isAfter(currentStart)) {
            currentStart = lastEnd;
          }
        }

        if (!currentStart.isBefore(availableEnd)) {
          continue;
        }

        if (currentStart.isAfter(task.deadline)) {
          continue;
        }

        final availableMinutes =
            availableEnd
                .difference(currentStart)
                .inMinutes;

        if (availableMinutes <= 0) {
          continue;
        }

        final remainingMinutes =
        (remainingDuration * 60).round();

        final scheduledMinutes =
        remainingMinutes <= availableMinutes
            ? remainingMinutes
            : availableMinutes;

        DateTime currentEnd = currentStart.add(
          Duration(minutes: scheduledMinutes),
        );

        if (currentEnd.isAfter(task.deadline)) {
          currentEnd = task.deadline;

          final adjustedMinutes =
              currentEnd
                  .difference(currentStart)
                  .inMinutes;

          if (adjustedMinutes <= 0) {
            continue;
          }

          remainingDuration -=
              adjustedMinutes / 60;

          daySchedule.add({
            'task': task,
            'startTime': currentStart,
            'endTime': currentEnd,
            'duration': adjustedMinutes / 60,
          });

          continue;
        }

        daySchedule.add({
          'task': task,
          'startTime': currentStart,
          'endTime': currentEnd,
          'duration': scheduledMinutes / 60,
        });

        remainingDuration -=
            scheduledMinutes / 60;
      }
    }

    return schedule;
  }
}