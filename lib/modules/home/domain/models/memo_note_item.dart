import 'dart:convert';

class MemoNoteItem {
  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime updatedAt;

  const MemoNoteItem({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    required this.updatedAt,
  });

  MemoNoteItem copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return MemoNoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'isPinned': isPinned,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory MemoNoteItem.fromJson(Map<String, dynamic> json) => MemoNoteItem(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        isPinned: json['isPinned'] as bool? ?? false,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static List<MemoNoteItem> get defaultNotes => [
        MemoNoteItem(
          id: '1',
          title: 'Idea: Flutter Spring Physics',
          content:
              'Flutter spring physics for widget drag and snap micro-interactions on the dashboard. Use ClampingScrollPhysics with curved springs.',
          isPinned: true,
          updatedAt: DateTime.now(),
        ),
      ];

  static String encodeList(List<MemoNoteItem> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<MemoNoteItem> decodeList(String jsonString) {
    try {
      final List decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((e) => MemoNoteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return defaultNotes;
    }
  }
}

