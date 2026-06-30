import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/task.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _apiService = ApiService();
  final _today = DateTime.now();
  List<Task> _tasks = [];
  bool _loading = true;
  bool _generating = false;
  String? _error;
  String? _summary;
  List<String> _achievements = [];
  List<String> _improvements = [];
  String? _motivation;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  String get _dateParam => DateFormat('yyyy-MM-dd').format(_today);
  String get _displayDate => DateFormat.yMMMMd().format(_today);

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

  Future<void> _generateReflection() async {
    setState(() { _generating = true; _error = null; });
    try {
      final tasksJson = _tasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'priority': t.priority,
        'deadline': t.deadline?.toIso8601String(),
      }).toList();
      final response = await _apiService.post('/ai/reflection', {
        'date': _dateParam,
        'completed': [],
        'pending': tasksJson,
      });
      final data = response.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _summary = data['summary'] as String?;
          _achievements = (data['achievements'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [];
          _improvements = (data['improvements'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [];
          _motivation = data['motivation'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate reflection: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflection')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_displayDate,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${_tasks.length} tasks today',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  if (_summary == null) ...[
                    _generating
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _generateReflection,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generate Reflection'),
                          ),
                  ],
                  if (_summary != null) ...[
                    Text('Summary',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(_summary!),
                    if (_achievements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Achievements',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      ..._achievements.map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✅ '),
                                Expanded(child: Text(a)),
                              ],
                            ),
                          )),
                    ],
                    if (_improvements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Areas for Improvement',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      ..._improvements.map((i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡 '),
                                Expanded(child: Text(i)),
                              ],
                            ),
                          )),
                    ],
                    if (_motivation != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text('🔥 '),
                              Expanded(child: Text(_motivation!)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _summary = null;
                          _achievements = [];
                          _improvements = [];
                          _motivation = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Again'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
