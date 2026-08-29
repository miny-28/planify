
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '../../data/models/task.dart';
import '../../data/models/available_time.dart';
import '../../data/services/task_storage_service.dart';
import '../../data/services/available_time_storage_service.dart';

import 'create_task_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget {
final VoidCallback onToggleTheme;
final bool isDarkMode;

const HomeScreen({
super.key,
required this.onToggleTheme,
required this.isDarkMode,
});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final TaskStorageService _taskStorageService =
TaskStorageService();

List<Task> tasks = [];

bool isLoading = true;
bool showAvailableMessage = true;

@override
void initState() {
super.initState();

_loadTasks();
_checkAvailableTime();
}

Future<void> _loadTasks() async {
final loadedTasks = await _taskStorageService.getTasks();

if (!mounted) {
return;
}

setState(() {
tasks = loadedTasks;
isLoading = false;
});
}

Future<void> _checkAvailableTime() async {
final storage = AvailableTimeStorageService();
final times = await storage.getTimes();

debugPrint('AVAILABLE TIMES COUNT: ${times.length}');

if (!mounted) {
return;
}

setState(() {
showAvailableMessage = times.isEmpty;
});
}

Future<void> _openAvailableTime() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const AvailableTimeScreen(),
),
);

if (!mounted) {
return;
}

await _checkAvailableTime();
}

void _closeAvailableMessage() {
setState(() {
showAvailableMessage = false;
});
}

Future<void> _openCreateTask() async {
final result = await Navigator.push(
context,
MaterialPageRoute(
builder: (context) => CreateTaskScreen(
onToggleTheme: widget.onToggleTheme,
isDarkMode: widget.isDarkMode,
),
),
);

if (result != null) {
await _loadTasks();
}
}

Future<void> _editTask(Task task) async {
final result = await Navigator.push(
context,
MaterialPageRoute(
builder: (context) => CreateTaskScreen(
onToggleTheme: widget.onToggleTheme,
isDarkMode: widget.isDarkMode,
taskToEdit: task,
),
),
);

if (result != null) {
await _loadTasks();
}
}

Future<void> _deleteTask(Task task) async {
final shouldDelete = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Delete Task'),
content: Text(
'Are you sure you want to delete "${task.title}"?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context, false);
},
child: const Text('Cancel'),
),
FilledButton(
onPressed: () {
Navigator.pop(context, true);
},
child: const Text('Delete'),
),
],
);
},
);

if (shouldDelete != true) {
return;
}

await _taskStorageService.deleteTask(task.id);

if (!mounted) {
return;
}

await _loadTasks();

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Task deleted successfully'),
),
);
}

List<Task> get activeTasks {
return tasks
    .where((task) => !task.isCompleted)
    .toList();
}

List<Task> get completedTasks {
return tasks
    .where((task) => task.isCompleted)
    .toList();
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Scaffold(
appBar: AppBar(
title: const Text(
'Planify',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
actions: [
IconButton(
onPressed: widget.onToggleTheme,
icon: Icon(
widget.isDarkMode
? Icons.light_mode
    : Icons.dark_mode,
),
tooltip: widget.isDarkMode
? 'Light Mode'
    : 'Dark Mode',
),
  IconButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    },
    icon: const Icon(
      Icons.person_outline,
    ),
    tooltip: 'Profile',
  ),
],
),
body: isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildAvailableMessage(context),

const SizedBox(height: 20),

Text(
'Welcome back! 👋',
style: theme
    .textTheme
    .headlineMedium
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
'Plan it. Work for it. Make it happen.',
style: theme
    .textTheme
    .bodyLarge
    ?.copyWith(
color:
colorScheme.onSurfaceVariant,
),
),

const SizedBox(height: 28),

Text(
"Today's Overview",
style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 14),

Row(
children: [
Expanded(
child: _buildSummaryCard(
context,
title: 'Tasks',
value:
activeTasks.length.toString(),
icon: Icons.task_alt,
),
),

const SizedBox(width: 12),

Expanded(
child: _buildSummaryCard(
context,
title: 'Completed',
value:
completedTasks.length.toString(),
icon:
Icons.check_circle_outline,
),
),
],
),

const SizedBox(height: 28),

Text(
'Upcoming Tasks',
style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 14),

if (activeTasks.isEmpty)
_buildSectionCard(
context,
child: Column(
children: [
Icon(
Icons.event_note_outlined,
size: 48,
color:
colorScheme.primary,
),

const SizedBox(height: 12),

Text(
'No upcoming tasks',
style: theme
    .textTheme
    .titleMedium
    ?.copyWith(
fontWeight:
FontWeight.w600,
),
),

const SizedBox(height: 6),

Text(
'Your upcoming tasks will appear here.',
textAlign:
TextAlign.center,
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: colorScheme
    .onSurfaceVariant,
),
),
],
),
)
else
...activeTasks.map(
(task) => _buildTaskCard(
context,
task,
),
),

const SizedBox(height: 28),

Text(
'Progress',
style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 14),

_buildSectionCard(
context,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,
children: [
Text(
'Overall Progress',
style: theme
    .textTheme
    .titleMedium
    ?.copyWith(
fontWeight:
FontWeight.w600,
),
),

Text(
'${tasks.isEmpty ? 0 : ((completedTasks.length / tasks.length) * 100).round()}%',
style: theme
    .textTheme
    .titleMedium
    ?.copyWith(
fontWeight:
FontWeight.bold,
color:
colorScheme.primary,
),
),
],
),

const SizedBox(height: 14),

LinearProgressIndicator(
value: tasks.isEmpty
? 0
    : completedTasks.length /
tasks.length,
),
],
),
),

const SizedBox(height: 28),

SizedBox(
width: double.infinity,
height: 52,
child: FilledButton.icon(
onPressed: _openCreateTask,
icon: const Icon(Icons.add),
label: const Text(
'Add New Task',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w600,
),
),
),
),

const SizedBox(height: 12),

SizedBox(
width: double.infinity,
height: 52,
child: OutlinedButton.icon(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const ScheduleScreen(),
),
);
},
icon: const Icon(
Icons.calendar_month,
),
label: const Text(
'View Schedule',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w600,
),
),
),
),
],
),
),
);
}

Widget _buildAvailableMessage(
BuildContext context,
) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [
Icon(
Icons.access_time,
color: colorScheme.primary,
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
showAvailableMessage
? 'Set your available time'
    : 'Available time is set',
style: theme
    .textTheme
    .titleMedium
    ?.copyWith(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
showAvailableMessage
? 'Choose when you are free so Planify can build your schedule.'
    : 'Your available time is saved. You can edit it anytime.',
style: theme
    .textTheme
    .bodySmall
    ?.copyWith(
color: colorScheme
    .onSurfaceVariant,
),
),

TextButton(
onPressed:
_openAvailableTime,
child: Text(
showAvailableMessage
? 'Set now'
    : 'Edit',
),
),
],
),
),

IconButton(
onPressed:
_closeAvailableMessage,
icon: const Icon(Icons.close),
),
],
),
),
);
}

Widget _buildTaskCard(
BuildContext context,
Task task,
) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Card(
elevation: 0,
margin:
const EdgeInsets.only(bottom: 12),
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [
Icon(
Icons.task_alt,
color: colorScheme.primary,
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
task.title,
style: theme
    .textTheme
    .titleMedium
    ?.copyWith(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
'Deadline: '
'${task.deadline.day}/'
'${task.deadline.month}/'
'${task.deadline.year}',
style: theme
    .textTheme
    .bodySmall
    ?.copyWith(
color: colorScheme
    .onSurfaceVariant,
),
),

const SizedBox(height: 4),

Text(
'${task.duration} ${task.durationUnit} • '
'${task.priority} Priority • '
'${task.difficulty}',
style: theme
    .textTheme
    .bodySmall
    ?.copyWith(
color: colorScheme
    .onSurfaceVariant,
),
),
],
),
),

PopupMenuButton<String>(
onSelected: (value) {
if (value == 'edit') {
_editTask(task);
} else if (value == 'delete') {
_deleteTask(task);
}
},
itemBuilder: (context) => [
const PopupMenuItem(
value: 'edit',
child: Row(
children: [
Icon(Icons.edit_outlined),
SizedBox(width: 10),
Text('Edit'),
],
),
),
const PopupMenuItem(
value: 'delete',
child: Row(
children: [
Icon(Icons.delete_outline),
SizedBox(width: 10),
Text('Delete'),
],
),
),
],
),
],
),
),
);
}

Widget _buildSummaryCard(
BuildContext context, {
required String title,
required String value,
required IconData icon,
}) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 30,
color: colorScheme.primary,
),

const SizedBox(height: 14),

Text(
value,
style: theme
    .textTheme
    .headlineSmall
    ?.copyWith(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
title,
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: colorScheme
    .onSurfaceVariant,
),
),
],
),
),
);
}

Widget _buildSectionCard(
BuildContext context, {
required Widget child,
}) {
return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(20),
child: child,
),
);
}
}

