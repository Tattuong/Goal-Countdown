import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/iap_constants.dart';
import '../../models/goal.dart';
import '../../providers/goals_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';
import 'add_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Goal _goal;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    setState(() => _remaining = _goal.targetDate.difference(DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _share() async {
    final shop = context.read<ShopProvider>();
    final goals = context.read<GoalsProvider>();
    final days = _goal.daysRemaining;
    final watermark = shop.hasNoWatermark ? '' : '\n\n— ${AppStrings.t(context, 'sharedVia')}';
    final text = '"${_goal.title}"\n$days days to go!$watermark';
    await Share.share(text);
    final canReward = await goals.rewardForShare();
    if (canReward) {
      await shop.addCoins(IapConstants.shareGoalReward, 'shareRewardEarned');
    }
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Goal>(
      context,
      MaterialPageRoute(builder: (_) => AddGoalScreen(editGoal: _goal)),
    );
    if (updated != null) {
      setState(() {
        _goal = updated;
        _updateRemaining();
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'deleteGoalConfirm')),
        content: Text(AppStrings.t(context, 'deleteGoalDesc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.t(context, 'cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t(context, 'delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<GoalsProvider>().deleteGoal(_goal.id);
      if (mounted) {
        AppToast.show(context, title: AppStrings.t(context, 'goalDeleted'));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPast = _remaining.isNegative;
    final isToday = _goal.isToday;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(decoration: BoxDecoration(gradient: _goal.category.gradient)),
          _DecorCircles(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopActions(onShare: _share, onEdit: _edit, onDelete: _delete),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CategoryIcon(category: _goal.category),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _goal.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (_goal.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _goal.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, height: 1.4),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      if (isToday)
                        _TodayBadge()
                      else if (isPast)
                        _PastBadge(days: _goal.daysRemaining.abs())
                      else
                        _CountdownDisplay(remaining: _remaining),
                      const SizedBox(height: 24),
                      Text(
                        DateFormat.yMMMMEEEEd().format(_goal.targetDate),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TopActions({required this.onShare, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
          const Spacer(),
          _CircleBtn(icon: Icons.share_rounded, onTap: onShare),
          const SizedBox(width: 8),
          _CircleBtn(icon: Icons.edit_outlined, onTap: onEdit),
          const SizedBox(width: 8),
          _CircleBtn(icon: Icons.delete_outline_rounded, onTap: onDelete),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final GoalCategory category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(category.icon, color: Colors.white, size: 40),
    );
  }
}

class _CountdownDisplay extends StatelessWidget {
  final Duration remaining;

  const _CountdownDisplay({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final totalHours = remaining.inHours;
    final days = remaining.inDays;
    final hours = totalHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TimeUnit(value: days, label: AppStrings.t(context, 'days')),
          _Separator(),
          _TimeUnit(value: hours, label: AppStrings.t(context, 'hours')),
          _Separator(),
          _TimeUnit(value: minutes, label: AppStrings.t(context, 'minutes')),
          _Separator(),
          _TimeUnit(value: seconds, label: AppStrings.t(context, 'seconds')),
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _TodayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'TODAY!',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}

class _PastBadge extends StatelessWidget {
  final int days;

  const _PastBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            days == 0 ? 'Today' : '$days days ago',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          Text(
            'Passed',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
