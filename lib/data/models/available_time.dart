import 'package:flutter/material.dart';
import '../services/available_time_storage_service.dart';

class AvailableTime {
  final String day;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  AvailableTime({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });
}

class AvailableTimeScreen extends StatefulWidget {
  const AvailableTimeScreen({super.key});

  @override
  State<AvailableTimeScreen> createState() =>
      _AvailableTimeScreenState();
}

class _AvailableTimeScreenState
    extends State<AvailableTimeScreen> {
  final AvailableTimeStorageService _storage =
  AvailableTimeStorageService();

  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  final Map<String, bool> selectedDays = {};
  final Map<String, TimeOfDay?> startTimes = {};
  final Map<String, TimeOfDay?> endTimes = {};

  @override
  void initState() {
    super.initState();

    for (final day in days) {
      selectedDays[day] = false;
      startTimes[day] = null;
      endTimes[day] = null;
    }

    _loadSavedTimes();
  }

  Future<void> _loadSavedTimes() async {
    final times = await _storage.getTimes();

    if (!mounted) {
      return;
    }

    setState(() {
      for (final time in times) {
        selectedDays[time.day] = time.isAvailable;

        startTimes[time.day] = TimeOfDay(
          hour: time.startTime.hour,
          minute: time.startTime.minute,
        );

        endTimes[time.day] = TimeOfDay(
          hour: time.endTime.hour,
          minute: time.endTime.minute,
        );
      }
    });
  }

  Future<void> _selectStartTime(String day) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: startTimes[day] ??
          const TimeOfDay(
            hour: 9,
            minute: 0,
          ),
    );

    if (selectedTime != null) {
      setState(() {
        startTimes[day] = selectedTime;
      });
    }
  }

  Future<void> _selectEndTime(String day) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: endTimes[day] ??
          const TimeOfDay(
            hour: 17,
            minute: 0,
          ),
    );

    if (selectedTime != null) {
      setState(() {
        endTimes[day] = selectedTime;
      });
    }
  }

  Future<void> _saveTimes() async {
    final List<AvailableTime> times = [];

    for (final day in days) {
      if (selectedDays[day] == true &&
          startTimes[day] != null &&
          endTimes[day] != null) {
        final start = startTimes[day]!;
        final end = endTimes[day]!;

        final now = DateTime.now();

        times.add(
          AvailableTime(
            day: day,
            startTime: DateTime(
              now.year,
              now.month,
              now.day,
              start.hour,
              start.minute,
            ),
            endTime: DateTime(
              now.year,
              now.month,
              now.day,
              end.hour,
              end.minute,
            ),
            isAvailable: true,
          ),
        );
      }
    }

    await _storage.saveTimes(times);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Time'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose your available days',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Select the days and the time you are available.',
          ),

          const SizedBox(height: 20),

          ...days.map(
                (day) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(day),
                      value: selectedDays[day],
                      onChanged: (value) {
                        setState(() {
                          selectedDays[day] =
                              value ?? false;
                        });
                      },
                    ),

                    if (selectedDays[day] == true)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _selectStartTime(day),
                              child: Text(
                                startTimes[day] == null
                                    ? 'Start time'
                                    : startTimes[day]!
                                    .format(context),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _selectEndTime(day),
                              child: Text(
                                endTimes[day] == null
                                    ? 'End time'
                                    : endTimes[day]!
                                    .format(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _saveTimes,
              child: const Text(
                'Save Available Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}