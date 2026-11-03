import 'dart:convert';
import 'package:flutter/material.dart';

class HabitStreakItem {
  final String id;
  final String title;
  final double current;
  final double target;
  final String unit;
  final String iconCode;
  final int streakDays;
  final int? colorValue;

  const HabitStreakItem({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    this.unit = '',
    required this.iconCode,
    this.streakDays = 0,
    this.colorValue,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => current >= target;

  String get displayProgress {
    if (unit.isEmpty) {
      if (streakDays > 0) return '$streakDays-Day 🔥';
      return '${current.toInt()} / ${target.toInt()}';
    }
    if (unit == 'gl') {
      return '${current.toInt()} / ${target.toInt()} gl';
    }
    return '${current.toInt()} $unit';
  }

  IconData get iconData {
    switch (iconCode) {
      case 'water':
      case 'hydration':
        return Icons.water_drop_rounded;
      case 'mindfulness':
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'book':
      case 'knowledge':
        return Icons.menu_book_rounded;
      case 'fitness':
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'code':
        return Icons.code_rounded;
      default:
        return Icons.local_fire_department_rounded;
    }
  }

  Color get progressColor {
    if (colorValue != null) return Color(colorValue!);
    switch (iconCode) {
      case 'water':
      case 'hydration':
        return const Color(0xFF0EA5E9);
      case 'mindfulness':
      case 'meditation':
        return const Color(0xFFEC4899);
      case 'book':
      case 'knowledge':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF10B981);
    }
  }

  HabitStreakItem copyWith({
    String? id,
    String? title,
    double? current,
    double? target,
    String? unit,
    String? iconCode,
    int? streakDays,
    int? colorValue,
  }) {
    return HabitStreakItem(
      id: id ?? this.id,
      title: title ?? this.title,
      current: current ?? this.current,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      iconCode: iconCode ?? this.iconCode,
      streakDays: streakDays ?? this.streakDays,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'current': current,
        'target': target,
        'unit': unit,
        'iconCode': iconCode,
        'streakDays': streakDays,
        'colorValue': colorValue,
      };

  factory HabitStreakItem.fromJson(Map<String, dynamic> json) =>
      HabitStreakItem(
        id: json['id'] as String,
        title: json['title'] as String,
        current: (json['current'] as num).toDouble(),
        target: (json['target'] as num).toDouble(),
        unit: json['unit'] as String? ?? '',
        iconCode: json['iconCode'] as String? ?? 'fire',
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
        colorValue: json['colorValue'] as int?,
      );

  static List<HabitStreakItem> get defaultHabits => const [
        HabitStreakItem(
          id: 'hydration',
          title: 'Hydration',
          current: 5,
          target: 8,
          unit: 'gl',
          iconCode: 'hydration',
          streakDays: 7,
          colorValue: 0xFF0EA5E9,
        ),
        HabitStreakItem(
          id: 'mindfulness',
          title: 'Mindfulness',
          current: 1,
          target: 1,
          iconCode: 'mindfulness',
          streakDays: 12,
          colorValue: 0xFFEC4899,
        ),
        HabitStreakItem(
          id: 'knowledge',
          title: 'Knowledge',
          current: 20,
          target: 30,
          unit: 'min',
          iconCode: 'knowledge',
          streakDays: 5,
          colorValue: 0xFFF97316,
        ),
      ];

  static String encodeList(List<HabitStreakItem> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<HabitStreakItem> decodeList(String jsonString) {
    try {
      final List decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((e) => HabitStreakItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return defaultHabits;
    }
  }
}

