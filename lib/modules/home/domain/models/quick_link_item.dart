import 'dart:convert';
import 'package:flutter/material.dart';

class QuickLinkItem {
  final String id;
  final String name;
  final String iconCode;
  final String? url;
  final String? route;
  final int? colorValue;

  const QuickLinkItem({
    required this.id,
    required this.name,
    required this.iconCode,
    this.url,
    this.route,
    this.colorValue,
  });

  IconData get iconData {
    switch (iconCode) {
      case 'search':
        return Icons.search_rounded;
      case 'chrome':
        return Icons.language_rounded;
      case 'gemini':
        return Icons.auto_awesome_rounded;
      case 'youtube':
        return Icons.play_circle_filled_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'planner':
        return Icons.event_note_rounded;
      case 'expenses':
        return Icons.account_balance_wallet_rounded;
      case 'clock':
        return Icons.access_time_rounded;
      case 'notes':
        return Icons.description_rounded;
      case 'settings':
        return Icons.tune_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  Color get accentColor {
    if (colorValue != null) return Color(colorValue!);
    switch (iconCode) {
      case 'search':
        return const Color(0xFFF97316);
      case 'chrome':
        return const Color(0xFF3B82F6);
      case 'gemini':
        return const Color(0xFFD946EF);
      case 'youtube':
        return const Color(0xFFEF4444);
      case 'camera':
        return const Color(0xFFEC4899);
      case 'planner':
        return const Color(0xFF10B981);
      case 'expenses':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': iconCode,
        'url': url,
        'route': route,
        'colorValue': colorValue,
      };

  factory QuickLinkItem.fromJson(Map<String, dynamic> json) => QuickLinkItem(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCode: json['iconCode'] as String? ?? 'link',
        url: json['url'] as String?,
        route: json['route'] as String?,
        colorValue: json['colorValue'] as int?,
      );

  static List<QuickLinkItem> get defaultShortcuts => const [
        QuickLinkItem(
          id: '1',
          name: 'Search',
          iconCode: 'search',
          url: 'https://www.google.com',
        ),
        QuickLinkItem(
          id: '2',
          name: 'Chrome',
          iconCode: 'chrome',
          url: 'https://chrome.google.com',
        ),
        QuickLinkItem(
          id: '3',
          name: 'Gemini',
          iconCode: 'gemini',
          url: 'https://gemini.google.com',
        ),
        QuickLinkItem(
          id: '4',
          name: 'YouTube',
          iconCode: 'youtube',
          url: 'https://www.youtube.com',
        ),
        QuickLinkItem(
          id: '5',
          name: 'Planner',
          iconCode: 'planner',
          route: '/planner',
        ),
      ];

  static String encodeList(List<QuickLinkItem> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<QuickLinkItem> decodeList(String jsonString) {
    try {
      final List decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => QuickLinkItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return defaultShortcuts;
    }
  }
}

