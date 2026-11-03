import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';
import '../../domain/models/memo_note_item.dart';
import '../../data/dashboard_local_storage.dart';

class QuickMemoSheet extends StatefulWidget {
  final List<MemoNoteItem> initialMemos;
  final ValueChanged<List<MemoNoteItem>> onSaved;

  const QuickMemoSheet({
    super.key,
    required this.initialMemos,
    required this.onSaved,
  });

  @override
  State<QuickMemoSheet> createState() => _QuickMemoSheetState();
}

class _QuickMemoSheetState extends State<QuickMemoSheet> {
  final _storage = DashboardLocalStorage();
  late List<MemoNoteItem> _memos;
  MemoNoteItem? _editingMemo;

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPinned = true;

  @override
  void initState() {
    super.initState();
    _memos = List.from(widget.initialMemos);
    _editingMemo = _memos.isNotEmpty ? _memos.first : null;
    _titleController =
        TextEditingController(text: _editingMemo?.title ?? 'Quick Note');
    _contentController =
        TextEditingController(text: _editingMemo?.content ?? '');
    _isPinned = _editingMemo?.isPinned ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveCurrent() {
    final title = _titleController.text.trim().isEmpty
        ? 'Untitled Note'
        : _titleController.text.trim();
    final content = _contentController.text.trim();

    final updated = (_editingMemo ??
            MemoNoteItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              content: content,
              isPinned: _isPinned,
              updatedAt: DateTime.now(),
            ))
        .copyWith(
      title: title,
      content: content,
      isPinned: _isPinned,
      updatedAt: DateTime.now(),
    );

    final idx = _memos.indexWhere((m) => m.id == updated.id);
    if (idx != -1) {
      _memos[idx] = updated;
    } else {
      _memos.insert(0, updated);
    }

    _storage.saveMemos(_memos);
    widget.onSaved(_memos);
    Navigator.pop(context);
  }

  void _createNew() {
    setState(() {
      _editingMemo = null;
      _titleController.text = '';
      _contentController.text = '';
      _isPinned = true;
    });
  }

  void _deleteCurrent() {
    if (_editingMemo == null) return;
    final id = _editingMemo!.id;
    setState(() {
      _memos.removeWhere((m) => m.id == id);
      _editingMemo = _memos.isNotEmpty ? _memos.first : null;
      _titleController.text = _editingMemo?.title ?? '';
      _contentController.text = _editingMemo?.content ?? '';
      _isPinned = _editingMemo?.isPinned ?? false;
    });
    _storage.deleteMemo(id);
    widget.onSaved(_memos);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded,
                      color: Color(0xFF3B82F6), size: 24),
                  const SizedBox(width: 8),
                  AppText(
                    _editingMemo != null ? 'Edit Memo' : 'New Memo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Pin memo',
                    icon: Icon(
                      _isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: _isPinned
                          ? const Color(0xFFF97316)
                          : const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinned = !_isPinned;
                      });
                    },
                  ),
                  if (_editingMemo != null)
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent),
                      onPressed: _deleteCurrent,
                    ),
                  IconButton(
                    tooltip: 'New note',
                    icon: const Icon(Icons.add_rounded,
                        color: Color(0xFF0F172A)),
                    onPressed: _createNew,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title field
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Memo Title...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Content field
          TextField(
            controller: _contentController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              color: Color(0xFF334155),
            ),
            decoration: InputDecoration(
              hintText: 'Write your thoughts, ideas, or reminders...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saveCurrent,
              child: const AppText(
                'Save Memo',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

