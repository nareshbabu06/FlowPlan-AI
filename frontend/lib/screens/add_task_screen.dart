import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime? _deadline;
  String _priority = 'medium';
  bool _saving = false;
  bool _nlLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted) return;
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
      );
      if (!mounted) return;
      if (time != null) {
        setState(() {
          _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _naturalLanguageInput() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Use Natural Language'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Submit report tomorrow at 5pm',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Parse'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;

    setState(() => _nlLoading = true);
    try {
      final response = await _apiService.post('/ai/natural-input', {'text': text});
      final data = response.data as Map<String, dynamic>;
      _titleController.text = data['title'] as String? ?? '';
      _descriptionController.text = data['description'] as String? ?? '';
      if (data['deadline'] != null) {
        _deadline = DateTime.parse(data['deadline'] as String);
      }
      if (data['priority'] != null) {
        _priority = data['priority'] as String;
      }
      if (data['estimated_duration'] != null) {
        _durationController.text = data['estimated_duration'].toString();
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _nlLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; });
    try {
      await _apiService.post('/tasks', {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'deadline': _deadline?.toIso8601String(),
        'priority': _priority,
        'estimated_duration': _durationController.text.isNotEmpty
            ? int.tryParse(_durationController.text)
            : null,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _nlLoading
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton.icon(
                      onPressed: _naturalLanguageInput,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Use Natural Language'),
                    ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Deadline'),
                  child: Text(
                    _deadline != null
                        ? DateFormat.yMd().add_jm().format(_deadline!)
                        : 'Select date & time',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_priority),
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
