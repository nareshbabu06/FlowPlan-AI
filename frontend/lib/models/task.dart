class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final String priority;
  final int? estimatedDuration;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    required this.priority,
    this.estimatedDuration,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        priority: json['priority'] as String? ?? 'medium',
        estimatedDuration: json['estimated_duration'] as int?,
      );
}
