import 'package:flutter/material.dart';

enum GoalCategory {
  exam,
  wedding,
  birthday,
  travel,
  deadline,
  other,
}

extension GoalCategoryExtension on GoalCategory {
  String get key => name;

  IconData get icon => switch (this) {
        GoalCategory.exam => Icons.school_rounded,
        GoalCategory.wedding => Icons.favorite_rounded,
        GoalCategory.birthday => Icons.cake_rounded,
        GoalCategory.travel => Icons.flight_rounded,
        GoalCategory.deadline => Icons.assignment_rounded,
        GoalCategory.other => Icons.star_rounded,
      };

  Color get color => switch (this) {
        GoalCategory.exam => const Color(0xFF4158D0),
        GoalCategory.wedding => const Color(0xFFE84393),
        GoalCategory.birthday => const Color(0xFFFF9F43),
        GoalCategory.travel => const Color(0xFF00B4D8),
        GoalCategory.deadline => const Color(0xFFE17055),
        GoalCategory.other => const Color(0xFF6C3CE0),
      };

  LinearGradient get gradient => switch (this) {
        GoalCategory.exam => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4158D0), Color(0xFF5B7FFF), Color(0xFF74B9FF)],
          ),
        GoalCategory.wedding => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE84393), Color(0xFFFD79A8), Color(0xFFFFB8D0)],
          ),
        GoalCategory.birthday => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B35), Color(0xFFFF9F43), Color(0xFFFFD93D)],
          ),
        GoalCategory.travel => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF90E0EF)],
          ),
        GoalCategory.deadline => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD63031), Color(0xFFE17055), Color(0xFFFFC0AD)],
          ),
        GoalCategory.other => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C3CE0), Color(0xFF9B6DFF), Color(0xFFFF6B9D)],
          ),
      };
}

class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final GoalCategory category;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetDate,
    required this.category,
    required this.createdAt,
  });

  Duration get remaining => targetDate.difference(DateTime.now());
  bool get isPast => remaining.isNegative;
  bool get isToday {
    final now = DateTime.now();
    return targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    GoalCategory? category,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetDate': targetDate.toIso8601String(),
        'category': category.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      targetDate: DateTime.parse(json['targetDate'] as String),
      category: GoalCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => GoalCategory.other,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
