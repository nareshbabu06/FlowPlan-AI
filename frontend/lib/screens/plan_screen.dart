import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/plan.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final _apiService = ApiService();
  final _today = DateTime.now();
  Plan? _plan;
  bool _loading = true;
  bool _generating = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  String get _dateParam => DateFormat('yyyy-MM-dd').format(_today);
  String get _displayDate => DateFormat.yMMMMd().format(_today);

  Future<void> _loadPlan() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await _apiService.get('/plans/$_dateParam');
      if (response.data != null && (response.data as Map<String, dynamic>).isNotEmpty) {
        _plan = Plan.fromJson(response.data as Map<String, dynamic>);
      }
    } on Exception {
      if (mounted) setState(() => _error = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generatePlan() async {
    setState(() { _generating = true; _error = null; });
    try {
      final response = await _apiService.post('/plans/generate', {
        'date': _dateParam,
        'available_hours': 8,
      });
      _plan = Plan.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _savePlan() async {
    if (_plan == null) return;
    setState(() => _saving = true);
    try {
      await _apiService.post('/plans/save', _plan!.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_displayDate,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_plan == null) _buildEmptyState(),
          if (_plan != null) _buildPlanContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 48),
        const Text('No plan yet. Tap Generate Plan to create your day.'),
        const SizedBox(height: 24),
        _generating
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _generatePlan,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Plan'),
              ),
      ],
    );
  }

  Widget _buildPlanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_plan!.summary, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        if (_generating)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!_generating) ...[
          if (_plan!.schedule.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Timeline',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._plan!.schedule.map(_buildScheduleCard),
          ],
          if (_plan!.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Tips',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._plan!.tips.map(_buildTipChip),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _savePlan,
                        child: const Text('Save Plan'),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _generating
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton(
                        onPressed: _generatePlan,
                        child: const Text('Regenerate'),
                      ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(item.time,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.taskTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${item.durationMinutes} min'),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.notes!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipChip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }
}
