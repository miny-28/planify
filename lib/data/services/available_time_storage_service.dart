import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/available_time.dart';

class AvailableTimeStorageService {
  static const String _key = 'available_times';

  Future<void> saveTimes(List<AvailableTime> times) async {
    final prefs = await SharedPreferences.getInstance();

    final data = times.map((time) {
      return {
        'day': time.day,
        'startTime': time.startTime.toIso8601String(),
        'endTime': time.endTime.toIso8601String(),
        'isAvailable': time.isAvailable,
      };
    }).toList();

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<List<AvailableTime>> getTimes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_key);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> data = jsonDecode(savedData);

    return data.map((item) {
      return AvailableTime(
        day: item['day'],
        startTime: DateTime.parse(item['startTime']),
        endTime: DateTime.parse(item['endTime']),
        isAvailable: item['isAvailable'] ?? true,
      );
    }).toList();
  }

  Future<void> clearTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}