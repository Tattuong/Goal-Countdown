import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/app_theme_preset.dart';
import '../../providers/goals_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../../widgets/goal_card.dart';
import '../goals/add_goal_screen.dart';
import '../goals/goal_detail_screen.dart';
import '../main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _addGoal() async {
    final shop = context.read<ShopProvider>();
    final goals = context.read<GoalsProvider>();

    if (!goals.canAddGoal(hasUnlimitedGoals: shop.hasUnlimitedGoals)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t(context, 'goalLimitReached')),
          action: SnackBarAction(
            label: AppStrings.t(context, 'openShop'),
            onPressed: () => MainShell.of(context)?.openShop(),
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGoalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final goals = context.watch<GoalsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = goals.sortedGoals;
    final skin = shop.activeSkin;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          _HeaderGlow(isDark: isDark, background: shop.activeBackground),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(onCoinTap: () => CoinPurchaseSheet.show(context)),
                Expanded(
                  child: sorted.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: sorted.length,
                          itemBuilder: (ctx, i) {
                            final goal = sorted[i];
                            return GoalCard(
                              key: ValueKey(goal.id),
                              goal: goal,
                              skin: skin,
                              hasReminders: shop.hasReminders,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.t(context, 'addGoal')),
      ),
    );
  }
}

class _HeaderGlow extends StatelessWidget {
  final bool isDark;
  final GoalBackground background;

  const _HeaderGlow({required this.isDark, required this.background});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              background.gradient.colors.first.withValues(alpha: isDark ? 0.35 : 0.18),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onCoinTap;

  const _TopBar({required this.onCoinTap});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalsProvider>();
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t(context, 'goalsTitle'),
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : AppColors.onSurface,
                  ),
                ),
                if (goals.goalCount > 0)
                  Text(
                    '${goals.goalCount} / ${shop.hasUnlimitedGoals ? '∞' : '5'} goals',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
              ],
            ),
          ),
          CoinBalanceChip(onTap: onCoinTap),
        ],
      ),
    );
  }
}

class _AdBanner extends StatelessWidget {
  final bool isDark;

  const _AdBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          AppStrings.t(context, 'adPlaceholder'),
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primary.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                  ),
                  child: const Icon(Icons.flag_rounded, size: 42, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.t(context, 'goalsEmpty'),
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.t(context, 'goalsEmptyHint'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  'Tap + below to get started',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
