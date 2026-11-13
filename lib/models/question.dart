import 'package:flutter/material.dart';

class QuestionCategory {
  final String id;
  final String name;
  final int count;
  final String icon;
  final Color color;

  const QuestionCategory({
    required this.id,
    required this.name,
    required this.count,
    this.icon = 'star',
    this.color = const Color(0xFF00F0FF),
  });

  factory QuestionCategory.fromJson(Map<String, dynamic> json) {
    Color parsedColor;
    if (json['color'] != null) {
      final hex = (json['color'] as String).replaceAll('#', '');
      parsedColor = Color(int.parse('FF$hex', radix: 16));
    } else {
      parsedColor = _defaultColorForCategory(json['id'] ?? '');
    }

    return QuestionCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      icon: json['icon'] ?? 'star',
      color: parsedColor,
    );
  }

  static Color _defaultColorForCategory(String id) {
    switch (id) {
      case 'quick':
        return const Color(0xFF00C6FF);
      case 'funny':
        return const Color(0xFFFF4B6E);
      case 'question':
        return const Color(0xFFA78BFA);
      case 'acting':
        return const Color(0xFFFFBE0B);
      case 'friends':
        return const Color(0xFF3DDC84);
      case 'creative':
        return const Color(0xFFFF7A00);
      default:
        return const Color(0xFF7C5CFC);
    }
  }

  IconData get iconData {
    switch (id) {
      case 'quick':
        return Icons.bolt_rounded;
      case 'funny':
        return Icons.sentiment_very_satisfied_rounded;
      case 'question':
        return Icons.chat_bubble_outline_rounded;
      case 'acting':
        return Icons.theater_comedy_rounded;
      case 'friends':
        return Icons.handshake_rounded;
      case 'creative':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}

class QuestionItem {
  final String id;
  final String type;
  final String categoryId;
  final String title;
  final String description;
  final int? duration;
  final bool timeLimit;
  final String difficulty;
  final String players;
  final List<String> tags;
  final String language;
  final bool isActive;

  const QuestionItem({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.title,
    required this.description,
    this.duration,
    required this.timeLimit,
    required this.difficulty,
    required this.players,
    required this.tags,
    required this.language,
    required this.isActive,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'challenge',
      categoryId: json['category'] ?? 'quick',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] as int?,
      timeLimit: json['time_limit'] == true || (json['duration'] != null && (json['duration'] as int) > 0),
      difficulty: json['difficulty'] ?? 'easy',
      players: json['players'] ?? 'single',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      language: json['language'] ?? 'uz',
      isActive: json['is_active'] ?? true,
    );
  }

  Color get categoryColor => QuestionCategory._defaultColorForCategory(categoryId);

  IconData get categoryIcon {
    switch (categoryId) {
      case 'quick':
        return Icons.bolt_rounded;
      case 'funny':
        return Icons.sentiment_very_satisfied_rounded;
      case 'question':
        return Icons.chat_bubble_outline_rounded;
      case 'acting':
        return Icons.theater_comedy_rounded;
      case 'friends':
        return Icons.handshake_rounded;
      case 'creative':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  String get categoryNameUz {
    switch (categoryId) {
      case 'quick':
        return 'Tezkor';
      case 'funny':
        return 'Kulgili';
      case 'question':
        return 'Savol';
      case 'acting':
        return 'Aktyorlik';
      case 'friends':
        return 'Do\'stlar';
      case 'creative':
        return 'Kreativ';
      default:
        return 'Topshiriq';
    }
  }
}
