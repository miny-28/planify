import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../../data/services/task_storage_service.dart';
import '../../data/services/available_time_storage_service.dart';
import '../../data/services/task_planner_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TaskStorageService _taskStorageService =
  TaskStorageService();

  final AvailableTimeStorageService _availableTimeStorageService =
  AvailableTimeStorageService();

  final TaskPlannerService _taskPlannerService =
  TaskPlannerService();

  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  Map<String, List<Map<String, dynamic>>> schedule = {};

  bool isLoading = true;
  String selectedDay = 'Saturday';

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final tasks = await _taskStorageService.getTasks();
    final availableTimes =
    await _availableTimeStorageService.getTimes();

    if (!mounted) {
      return;
    }

    final plannedSchedule =
    _taskPlannerService.createDailySchedule(
      tasks,
      availableTimes,
    );

    setState(() {
      schedule = plannedSchedule;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Schedule',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          const SizedBox(height: 16),

          _buildCalendarDays(context),

          const SizedBox(height: 20),

          Expanded(
            child: _buildDaySchedule(
              context,
              selectedDay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDays(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selectedDay == day;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = day;
              });
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    day.substring(0, 3),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _getDayNumber(day),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayNumber(String day) {
    final now = DateTime.now();

    final dayNumbers = {
      'Saturday': 6,
      'Sunday': 7,
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
    };

    final targetDay = dayNumbers[day]!;

    int difference = targetDay - now.weekday;

    if (difference < 0) {
      difference += 7;
    }

    final date = now.add(
      Duration(days: difference),
    );

    return date.day.toString();
  }

  Widget _buildDaySchedule(
      BuildContext context,
      String day,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dayTasks = schedule[day] ?? [];

    if (dayTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 60,
                color: colorScheme.primary,
              ),

              const SizedBox(height: 16),

              Text(
                'No tasks planned',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'There are no scheduled tasks for $day.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      children: [
        Text(
          day,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        ...dayTasks.map(
              (item) => _buildScheduledTaskCard(
            context,
            item,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledTaskCard(
      BuildContext context,
      Map<String, dynamic> item,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Task task = item['task'];
    final double duration = item['duration'];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${duration.toStringAsFixed(1)} hours',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Deadline: '
                        '${task.deadline.day}/'
                        '${task.deadline.month}/'
                        '${task.deadline.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.schedule,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}