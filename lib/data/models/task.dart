class Task {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final double duration;
  final String durationUnit;
  final String category;
  final String priority;
  final String difficulty;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.duration,
    required this.durationUnit,
    required this.category,
    required this.priority,
    required this.difficulty,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'duration': duration,
      'durationUnit': durationUnit,
      'category': category,
      'priority': priority,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      duration: json['duration'],
      durationUnit: json['durationUnit'],
      category: json['category'],
      priority: json['priority'],
      difficulty: json['difficulty'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}