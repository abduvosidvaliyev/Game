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
        return const Color(0xFF00F0FF); // Cyan
      case 'funny':
        return const Color(0xFFFF007F); // Neon Pink
      case 'question':
        return const Color(0xFF9D00FF); // Electric Purple
      case 'acting':
        return const Color(0xFFFFBE0B); // Amber / Gold
      case 'friends':
        return const Color(0xFF00FF87); // Emerald Green
      case 'creative':
        return const Color(0xFFFF5252); // Coral Red
      default:
        return const Color(0xFF00F0FF);
    }
  }

  IconData get iconData {
    switch (id) {
      case 'quick':
        return Icons.bolt;
      case 'funny':
        return Icons.sentiment_very_satisfied;
      case 'question':
        return Icons.help_outline;
      case 'acting':
        return Icons.theater_comedy;
      case 'friends':
        return Icons.groups;
      case 'creative':
        return Icons.lightbulb_outline;
      default:
        return Icons.casino;
    }
  }
}

class QuestionItem {
  final String id;
  final String type; // 'challenge' or 'question'
  final String categoryId;
  final String title;
  final String description;
  final int? duration; // seconds if timed
  final bool timeLimit; // whether there is a timer
  final String difficulty; // 'easy', 'medium', 'hard'
  final String players; // 'single', 'group'
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

  String get difficultyUz {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Oson';
      case 'medium':
        return "O'rtacha";
      case 'hard':
        return 'Qiyin';
      default:
        return difficulty;
    }
  }

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF00FF87);
      case 'medium':
        return const Color(0xFFFFBE0B);
      case 'hard':
        return const Color(0xFFFF3366);
      default:
        return const Color(0xFF00F0FF);
    }
  }
}

