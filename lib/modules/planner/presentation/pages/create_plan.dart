import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:j_phone/core/const/theme/app_color.dart';
import 'package:j_phone/core/widgets/app_bar.dart';
import 'package:j_phone/core/widgets/app_elevated_button.dart';
import 'package:j_phone/core/widgets/app_text.dart';
import 'package:j_phone/modules/planner/domain/planner_enums.dart';
import 'package:j_phone/modules/planner/presentation/bloc/planner_bloc.dart';

class CreatePlan extends StatefulWidget {
  const CreatePlan({super.key});

  @override
  State<CreatePlan> createState() => _CreatePlanState();
}

class _CreatePlanState extends State<CreatePlan> {
  int _selectedTab = 0; // 0 = Task, 1 = Target

  // Task Form Controllers
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedTargetId;
  DateTime? _selectedDueDate;

  // Target Form Controllers
  final _targetNameController = TextEditingController();
  final _targetDescController = TextEditingController();
  DateTime? _targetDeadline;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    _targetNameController.dispose();
    _targetDescController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<PlannerBloc>();

    if (_selectedTab == 0) {
      // Create Task via Bloc Event
      bloc.add(
        PlannerTaskCreated(
          title: _taskTitleController.text.trim(),
          description: _taskDescController.text.trim().isNotEmpty
              ? _taskDescController.text.trim()
              : null,
          targetId: _selectedTargetId,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
        ),
      );
    } else {
      // Create Target via Bloc Event
      bloc.add(
        PlannerTargetCreated(
          name: _targetNameController.text.trim(),
          description: _targetDescController.text.trim().isNotEmpty
              ? _targetDescController.text.trim()
              : null,
          deadline: _targetDeadline,
        ),
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Create Plan', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented Switch: Task vs Target
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSegmentButton(
                          title: 'New Task',
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildSegmentButton(
                          title: 'New Target',
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (_selectedTab == 0) _buildTaskForm() else _buildTargetForm(),

                const SizedBox(height: 32),

                // Submit Button
                AppElevatedButton(
                  text: _selectedTab == 0 ? 'Create Task' : 'Create Target',
                  icon: Icons.check,
                  iconSize: 20,
                  borderWidth: 0,
                  borderRadius: 100,
                  shadowColor: const Color(0xFFF97316).withValues(alpha: 0.35),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.buttonGradient,
                      AppColors.buttonGradient2,
                      AppColors.buttonGradient3,
                    ],
                  ),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: AppText(
          title,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : AppColors.neutral.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildTaskForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _taskTitleController,
          label: 'Task Title',
          hint: 'e.g., Complete Flutter assignment',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _taskDescController,
          label: 'Description (optional)',
          hint: 'Add any extra notes...',
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Target Selector
        BlocBuilder<PlannerBloc, PlannerState>(
          builder: (context, state) {
            final targets = state is PlannerLoaded ? state.targets : [];
            if (targets.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Attach to Target',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const AppText('None'),
                      selected: _selectedTargetId == null,
                      onSelected: (val) {
                        setState(() => _selectedTargetId = null);
                      },
                    ),
                    ...targets.map((t) {
                      return ChoiceChip(
                        label: AppText(t.name),
                        selected: _selectedTargetId == t.id,
                        onSelected: (val) {
                          setState(() => _selectedTargetId = val ? t.id : null);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),

        // Priority Selector
        const AppText(
          'Priority',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral,
        ),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _selectedPriority = priority);
                  },
                  child: AppText(
                    priority.name.toUpperCase(),
                    color: isSelected ? AppColors.primary : AppColors.neutral,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Due Date Picker
        _buildDatePickerTile(
          label: 'Due Date',
          date: _selectedDueDate,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() => _selectedDueDate = picked);
            }
          },
          onClear: () => setState(() => _selectedDueDate = null),
        ),
      ],
    );
  }

  Widget _buildTargetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _targetNameController,
          label: 'Target Name',
          hint: 'e.g., Master Clean Architecture',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Target name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _targetDescController,
          label: 'Description (optional)',
          hint: 'What does achieving this target look like?',
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildDatePickerTile(
          label: 'Target Deadline',
          date: _targetDeadline,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
            );
            if (picked != null) {
              setState(() => _targetDeadline = picked);
            }
          },
          onClear: () => setState(() => _targetDeadline = null),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.neutral.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final formatted = date != null
        ? DateFormat('MMM dd, yyyy').format(date)
        : 'No date set';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label,
                    fontSize: 12,
                    color: AppColors.neutral.withValues(alpha: 0.6),
                  ),
                  AppText(
                    formatted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? AppColors.neutral
                        : AppColors.neutral.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
