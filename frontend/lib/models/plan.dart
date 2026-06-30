class ScheduleItem {
  final String time;
  final String taskTitle;
  final int durationMinutes;
  final String? notes;

  ScheduleItem({
    required this.time,
    required this.taskTitle,
    required this.durationMinutes,
    this.notes,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        time: json['time'] as String,
        taskTitle: json['task_title'] as String,
        durationMinutes: json['duration_minutes'] as int,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'time': time,
        'task_title': taskTitle,
        'duration_minutes': durationMinutes,
        'notes': notes,
      };
}

class Plan {
  final String? id;
  final String date;
  final String summary;
  final List<ScheduleItem> schedule;
  final List<String> tips;

  Plan({
    this.id,
    required this.date,
    required this.summary,
    required this.schedule,
    required this.tips,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as String?,
        date: json['date'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        schedule: (json['schedule'] as List<dynamic>?)
                ?.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tips: (json['tips'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'summary': summary,
        'schedule': schedule.map((e) => e.toJson()).toList(),
        'tips': tips,
      };
}
