import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _apiService = ApiService();
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await _apiService.get('/tasks');
      final list = (response.data as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() => _tasks = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _deleteTask(Task task) async {
    try {
      await _apiService.delete('/tasks/${task.id}');
      if (mounted) setState(() => _tasks.remove(task));
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
      return false;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadTasks, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Stack(
        children: [
          const Center(child: Text('No tasks yet. Tap + to add one.')),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _openAddTask,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadTasks,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return Dismissible(
                key: ValueKey(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _deleteTask(task),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: task.deadline != null
                        ? Text('Due: ${DateFormat.yMd().add_jm().format(task.deadline!)}')
                        : null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority).withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: TextStyle(
                          color: _priorityColor(task.priority),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _openAddTask,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddTask() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (result == true) _loadTasks();
  }
}
