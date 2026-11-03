import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/app_text.dart';
import 'dashboard_card_container.dart';

class QuickMemoCard extends StatefulWidget {
  final int widthColumns;

  const QuickMemoCard({
    super.key,
    this.widthColumns = 4,
  });

  @override
  State<QuickMemoCard> createState() => _QuickMemoCardState();
}

class _QuickMemoCardState extends State<QuickMemoCard> {
  String _title = 'Idea: Flutter Spring Physics';
  String _content =
      'Flutter spring physics for widget drag and snap micro-interactions on the dashboard.';
  bool _isPinned = true;

  void _openEditor() {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController(text: _title);
    final contentController = TextEditingController(text: _content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note_rounded,
                          color: Color(0xFF3B82F6), size: 24),
                      SizedBox(width: 8),
                      AppText(
                        'Quick Memo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: _isPinned
                          ? const Color(0xFFF97316)
                          : const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      setSheetState(() {
                        _isPinned = !_isPinned;
                      });
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
                decoration: InputDecoration(
                  labelText: 'Memo',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      if (titleController.text.trim().isNotEmpty) {
                        _title = titleController.text.trim();
                      }
                      _content = contentController.text.trim();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const AppText(
                    'Save Memo',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: _openEditor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          DashboardCardHeader(
            title: 'Quick Memo',
            icon: Icons.notes_rounded,
            iconColor: const Color(0xFF3B82F6),
            badge: DashboardBadge(
              label: _isPinned ? 'Pinned' : 'Recent',
              backgroundColor: const Color(0xFFF1F5F9),
              textColor: const Color(0xFF475569),
              fontSize: 10,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            ),
          ),
          const SizedBox(height: 8),

          // Inner preview box
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          _title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF97316),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Flexible(
                    child: AppText(
                      _content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
