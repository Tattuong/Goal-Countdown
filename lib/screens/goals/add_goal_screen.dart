import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/iap_constants.dart';
import '../../models/goal.dart';
import '../../providers/goals_provider.dart';
import '../../providers/shop_provider.dart';
import '../../screens/main_shell.dart';
import '../../widgets/app_toast.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? editGoal;

  const AddGoalScreen({super.key, this.editGoal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late DateTime _targetDate;
  late GoalCategory _category;
  bool _saving = false;

  bool get _isEditing => widget.editGoal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final g = widget.editGoal!;
      _titleCtrl.text = g.title;
      _descCtrl.text = g.description;
      _targetDate = g.targetDate;
      _category = g.category;
    } else {
      _targetDate = DateTime.now().add(const Duration(days: 30));
      _category = GoalCategory.other;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate.isAfter(DateTime.now()) ? _targetDate : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;
    setState(() => _saving = true);

    final goals = context.read<GoalsProvider>();
    final shop = context.read<ShopProvider>();

    if (_isEditing) {
      final updated = widget.editGoal!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        targetDate: _targetDate,
        category: _category,
      );
      await goals.updateGoal(updated);
      if (mounted) {
        AppToast.show(context, title: AppStrings.t(context, 'goalSaved'), icon: Icons.check_circle_outline);
        Navigator.pop(context, updated);
      }
    } else {
      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        targetDate: _targetDate,
        category: _category,
        createdAt: DateTime.now(),
      );
      final ok = await goals.addGoal(goal, hasUnlimitedGoals: shop.hasUnlimitedGoals);
      if (!mounted) return;
      if (!ok) {
        setState(() => _saving = false);
        AppToast.show(context, title: AppStrings.t(context, 'goalLimitReached'), icon: Icons.lock_outline);
        return;
      }
      final canReward = await goals.rewardForAddGoal();
      if (canReward) {
        await shop.addCoins(IapConstants.addGoalReward, 'addGoalRewardEarned');
      }
      if (mounted) {
        AppToast.show(context, title: AppStrings.t(context, 'goalSaved'), icon: Icons.check_circle_outline);
        Navigator.pop(context, goal);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat.yMMMMd().format(_targetDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.t(context, _isEditing ? 'editGoal' : 'addGoal')),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppStrings.t(context, 'save'), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(AppStrings.t(context, 'goalTitle')),
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: AppStrings.t(context, 'goalTitleHint'),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a goal name' : null,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
            ),
            const SizedBox(height: 16),
            _SectionTitle(AppStrings.t(context, 'goalDescription')),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                hintText: AppStrings.t(context, 'goalDescriptionHint'),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            _SectionTitle(AppStrings.t(context, 'goalDate')),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(AppStrings.t(context, 'goalCategory')),
            _CategoryPicker(
              selected: _category,
              onSelect: (c) => setState(() => _category = c),
              hasCustomIcons: context.watch<ShopProvider>().hasCustomIcons,
            ),
            const SizedBox(height: 32),
            _GoalPreview(
              title: _titleCtrl.text.isNotEmpty ? _titleCtrl.text : AppStrings.t(context, 'goalTitle'),
              category: _category,
              targetDate: _targetDate,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _PremiumCategory {
  final GoalCategory baseCategory;
  final IconData icon;
  final String labelKey;
  final LinearGradient gradient;
  final Color color;

  const _PremiumCategory({
    required this.baseCategory,
    required this.icon,
    required this.labelKey,
    required this.gradient,
    required this.color,
  });
}

final _premiumCategories = [
  const _PremiumCategory(
    baseCategory: GoalCategory.other,
    icon: Icons.emoji_events_rounded,
    labelKey: 'cat_achievement',
    gradient: LinearGradient(colors: [Color(0xFFFFB020), Color(0xFFFFD700)]),
    color: Color(0xFFFFB020),
  ),
  const _PremiumCategory(
    baseCategory: GoalCategory.other,
    icon: Icons.favorite_rounded,
    labelKey: 'cat_health',
    gradient: LinearGradient(colors: [Color(0xFF00B894), Color(0xFF55EFC4)]),
    color: Color(0xFF00B894),
  ),
  const _PremiumCategory(
    baseCategory: GoalCategory.other,
    icon: Icons.account_balance_wallet_rounded,
    labelKey: 'cat_finance',
    gradient: LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF)]),
    color: Color(0xFF0984E3),
  ),
  const _PremiumCategory(
    baseCategory: GoalCategory.other,
    icon: Icons.self_improvement_rounded,
    labelKey: 'cat_personal',
    gradient: LinearGradient(colors: [Color(0xFFE84393), Color(0xFFFFB8D0)]),
    color: Color(0xFFE84393),
  ),
];

class _CategoryPicker extends StatelessWidget {
  final GoalCategory selected;
  final ValueChanged<GoalCategory> onSelect;
  final bool hasCustomIcons;

  const _CategoryPicker({
    required this.selected,
    required this.onSelect,
    this.hasCustomIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalCategory.values.map((cat) {
            final isSelected = selected == cat;
            return GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? cat.gradient : null,
                  color: isSelected ? null : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.t(context, 'cat_${cat.name}'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (hasCustomIcons) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.stars_rounded, size: 14, color: AppColors.coin),
              const SizedBox(width: 4),
              Text(
                'Custom Icons (Premium)',
                style: TextStyle(fontSize: 12, color: AppColors.coin, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _premiumCategories.map((pc) {
              final isSelected = selected == pc.baseCategory;
              return GestureDetector(
                onTap: () => onSelect(pc.baseCategory),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? pc.gradient : null,
                    color: isSelected ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: pc.color.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(pc.icon, size: 18, color: isSelected ? Colors.white : pc.color),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.t(context, pc.labelKey),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => MainShell.of(context)?.openShop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Purchase Custom Icons to unlock more categories',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GoalPreview extends StatelessWidget {
  final String title;
  final GoalCategory category;
  final DateTime targetDate;

  const _GoalPreview({
    required this.title,
    required this.category,
    required this.targetDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final days = target.difference(today).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: category.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      days >= 0 ? '$days days left' : '${(-days)} days ago',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$days',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
