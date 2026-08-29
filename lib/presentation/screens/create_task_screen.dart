import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../../data/services/task_storage_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  // null = Create mode
  // Task = Edit mode
  final Task? taskToEdit;

  const CreateTaskScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    this.taskToEdit,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TaskStorageService _taskStorageService =
  TaskStorageService();

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  final TextEditingController _durationController =
  TextEditingController();

  DateTime? selectedDate;

  bool hasSubmitted = false;
  bool hasRequiredError = false;

  String selectedDurationUnit = 'Hours';
  String selectedPriority = 'Medium';
  String selectedDifficulty = 'Medium';
  String selectedCategory = 'Personal';

  @override
  void initState() {
    super.initState();

    final task = widget.taskToEdit;

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _durationController.text = task.duration.toString();

      selectedDate = task.deadline;

      selectedDurationUnit = task.durationUnit;
      selectedPriority = task.priority;
      selectedDifficulty = task.difficulty;
      selectedCategory = task.category;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    setState(() {
      hasSubmitted = true;
    });

    final isFormValid =
    _formKey.currentState!.validate();

    if (!isFormValid || selectedDate == null) {
      setState(() {
        hasRequiredError = true;
      });

      return;
    }

    setState(() {
      hasRequiredError = false;
    });

    final existingTask = widget.taskToEdit;

    final task = Task(
      // Keep the old ID when editing.
      // Generate a new ID only when creating.
      id: existingTask?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      title: _titleController.text.trim(),

      description: _descriptionController.text.trim(),

      deadline: selectedDate!,

      duration: double.parse(
        _durationController.text,
      ),

      durationUnit: selectedDurationUnit,

      category: selectedCategory,

      priority: selectedPriority,

      difficulty: selectedDifficulty,

      // Keep completion status when editing.
      isCompleted:
      existingTask?.isCompleted ?? false,
    );

    if (widget.taskToEdit == null) {
      await _taskStorageService.addTask(task);
    } else {
      await _taskStorageService.updateTask(task);
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.taskToEdit == null
              ? 'Task created successfully'
              : 'Task updated successfully',
        ),
      ),
    );

    Navigator.pop(context, task);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEditMode = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Task' : 'Create Task',
          style: const TextStyle(
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
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // Title
              Text(
                isEditMode
                    ? 'Edit Your Task'
                    : 'Create Your Task',
                style: theme
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Progress is still progress, no matter how slow',
                style: theme
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  color:
                  colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              // Task Title
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Task Title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _titleController,

                decoration: InputDecoration(
                  hintText:
                  'What do you need to do?',

                  filled: true,

                  fillColor: colorScheme
                      .surfaceContainerHighest
                      .withValues(
                    alpha: 0.4,
                  ),

                  errorStyle: const TextStyle(
                    color: Colors.red,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Description
              Row(
                children: [
                  Icon(
                    Icons.notes_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _descriptionController,

                maxLines: 4,

                decoration: InputDecoration(
                  hintText:
                  'Add some details about this task...',

                  filled: true,

                  fillColor: colorScheme
                      .surfaceContainerHighest
                      .withValues(
                    alpha: 0.4,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Deadline
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Deadline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: _selectDate,

                  icon: const Icon(
                    Icons.calendar_today_outlined,
                  ),

                  label: Text(
                    selectedDate == null
                        ? 'Select Deadline'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),

                  style:
                  OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              if (hasSubmitted &&
                  selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(
                    top: 6,
                    left: 4,
                  ),

                  child: Text(
                    'Required',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Duration
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  // Duration number
                  Expanded(
                    child: TextFormField(
                      controller:
                      _durationController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      InputDecoration(
                        hintText: '2',

                        filled: true,

                        fillColor: colorScheme
                            .surfaceContainerHighest
                            .withValues(
                          alpha: 0.4,
                        ),

                        errorStyle:
                        const TextStyle(
                          color: Colors.red,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                          BorderSide.none,
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                          BorderSide.none,
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                          BorderSide(
                            color:
                            colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Required';
                        }

                        final duration =
                        double.tryParse(value);

                        if (duration == null ||
                            duration <= 0) {
                          return 'Invalid';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Duration unit
                  Expanded(
                    child:
                    DropdownButtonFormField<String>(
                      initialValue:
                      selectedDurationUnit,

                      decoration:
                      InputDecoration(
                        filled: true,

                        fillColor: colorScheme
                            .surfaceContainerHighest
                            .withValues(
                          alpha: 0.4,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                          BorderSide.none,
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                          BorderSide.none,
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          borderSide:
                          BorderSide(
                            color:
                            colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'Minutes',
                          child: Text('Minutes'),
                        ),

                        DropdownMenuItem(
                          value: 'Hours',
                          child: Text('Hours'),
                        ),

                        DropdownMenuItem(
                          value: 'Days',
                          child: Text('Days'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedDurationUnit =
                                value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Category
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label:
                      const Text('Personal'),

                      selected:
                      selectedCategory ==
                          'Personal',

                      onSelected: (selected) {
                        setState(() {
                          selectedCategory =
                          'Personal';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Work'),

                      selected:
                      selectedCategory == 'Work',

                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = 'Work';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ChoiceChip(
                      label:
                      const Text('Study'),

                      selected:
                      selectedCategory ==
                          'Study',

                      onSelected: (selected) {
                        setState(() {
                          selectedCategory =
                          'Study';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Priority
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Low'),

                      selected:
                      selectedPriority == 'Low',

                      onSelected: (selected) {
                        setState(() {
                          selectedPriority = 'Low';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ChoiceChip(
                      label:
                      const Text('Medium'),

                      selected:
                      selectedPriority ==
                          'Medium',

                      onSelected: (selected) {
                        setState(() {
                          selectedPriority =
                          'Medium';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ChoiceChip(
                      label: const Text('High'),

                      selected:
                      selectedPriority ==
                          'High',

                      onSelected: (selected) {
                        setState(() {
                          selectedPriority = 'High';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Difficulty
              Row(
                children: [
                  Icon(
                    Icons.bolt_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Easy'),

                      selected:
                      selectedDifficulty ==
                          'Easy',

                      onSelected: (selected) {
                        setState(() {
                          selectedDifficulty =
                          'Easy';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ChoiceChip(
                      label:
                      const Text('Medium'),

                      selected:
                      selectedDifficulty ==
                          'Medium',

                      onSelected: (selected) {
                        setState(() {
                          selectedDifficulty =
                          'Medium';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Hard'),

                      selected:
                      selectedDifficulty ==
                          'Hard',

                      onSelected: (selected) {
                        setState(() {
                          selectedDifficulty =
                          'Hard';
                        });
                      },

                      showCheckmark: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 34),

              // Save / Create Task Button
              SizedBox(
                width: double.infinity,
                height: 56,

                child: FilledButton.icon(
                  onPressed: _saveTask,

                  icon: Icon(
                    isEditMode
                        ? Icons.save_rounded
                        : Icons.check_rounded,
                  ),

                  label: Text(
                    isEditMode
                        ? 'Save Changes'
                        : 'Create Task',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    hasRequiredError
                        ? Colors.red
                        : colorScheme.primary,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}