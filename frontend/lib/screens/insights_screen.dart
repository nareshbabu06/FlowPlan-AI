import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/task.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  final _apiService = ApiService();
  List<Task> _tasks = [];
  List<Map<String, dynamic>> _prioritized = [];
  bool _loading = true;
  bool _prioritizing = false;
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

  Future<void> _prioritize() async {
    setState(() { _prioritizing = true; _error = null; });
    try {
      final tasksJson = _tasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'priority': t.priority,
        'deadline': t.deadline?.toIso8601String(),
        'estimated_duration_minutes': t.estimatedDuration,
      }).toList();
      final response = await _apiService.post('/ai/prioritize', {'tasks': tasksJson});
      final data = response.data as Map<String, dynamic>;
      final list = (data['prioritized_tasks'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) setState(() => _prioritized = list);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get insights: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _prioritizing = false);
    }
  }

  int get _highCount => _tasks.where((t) => t.priority == 'high').length;
  int get _mediumCount => _tasks.where((t) => t.priority == 'medium').length;
  int get _lowCount => _tasks.where((t) => t.priority == 'low').length;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null && _tasks.isEmpty) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Task Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('Total', '${_tasks.length}', Colors.blue),
              _statCard('High', '$_highCount', Colors.red),
              _statCard('Medium', '$_mediumCount', Colors.amber),
              _statCard('Low', '$_lowCount', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          if (_tasks.isNotEmpty)
            _prioritizing
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _prioritize,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Get AI Insights'),
                  ),
          if (_prioritized.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Prioritized Tasks',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._prioritized.asMap().entries.map((entry) {
              final item = entry.value;
              final task = _tasks.cast<Task?>().firstWhere(
                    (t) => t?.id == item['task_id'],
                    orElse: () => null,
                  );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text('${entry.key + 1}',
                            style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task?.title ?? item['task_id'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item['reasoning'] as String? ?? '',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
