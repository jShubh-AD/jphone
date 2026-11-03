import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';
import '../../domain/models/quick_link_item.dart';
import '../../data/dashboard_local_storage.dart';

class QuickLinksSheet extends StatefulWidget {
  final List<QuickLinkItem> initialItems;
  final ValueChanged<List<QuickLinkItem>> onSaved;

  const QuickLinksSheet({
    super.key,
    required this.initialItems,
    required this.onSaved,
  });

  @override
  State<QuickLinksSheet> createState() => _QuickLinksSheetState();
}

class _QuickLinksSheetState extends State<QuickLinksSheet> {
  late List<QuickLinkItem> _items;
  final _storage = DashboardLocalStorage();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  void _addItemDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String selectedIcon = 'search';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const AppText(
            'Add Shortcut',
            fontWeight: FontWeight.w700,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL or Route (e.g. /planner)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  'search',
                  'chrome',
                  'gemini',
                  'youtube',
                  'camera',
                  'planner',
                  'expenses',
                  'clock',
                ].map((iconKey) {
                  final isSelected = selectedIcon == iconKey;
                  return ChoiceChip(
                    label: AppText(iconKey),
                    selected: isSelected,
                    selectedColor: const Color(0xFFF97316).withValues(alpha: 0.2),
                    onSelected: (val) {
                      setDialogState(() {
                        selectedIcon = iconKey;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const AppText('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final newItem = QuickLinkItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: titleController.text.trim(),
                  iconCode: selectedIcon,
                  url: urlController.text.trim().startsWith('http')
                      ? urlController.text.trim()
                      : null,
                  route: urlController.text.trim().startsWith('/')
                      ? urlController.text.trim()
                      : null,
                );
                setState(() {
                  _items.add(newItem);
                });
                widget.onSaved(_items);
                _storage.saveQuickLinks(_items);
                Navigator.pop(ctx);
              },
              child: const AppText('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Customize Quick Links',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: Color(0xFFF97316)),
                onPressed: _addItemDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
                widget.onSaved(_items);
                _storage.saveQuickLinks(_items);
              },
              children: [
                for (int i = 0; i < _items.length; i++)
                  ListTile(
                    key: ValueKey(_items[i].id),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _items[i].accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_items[i].iconData,
                          color: _items[i].accentColor, size: 20),
                    ),
                    title: AppText(_items[i].name,
                        fontWeight: FontWeight.w600),
                    subtitle: AppText(_items[i].route ?? _items[i].url ?? 'Shortcut',
                        maxLines: 1),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          _items.removeAt(i);
                        });
                        widget.onSaved(_items);
                        _storage.saveQuickLinks(_items);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
              onPressed: () => Navigator.pop(context),
              child: const AppText('Done',
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

