import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_theme_preset.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final GoalCardSkin skin;
  final bool hasReminders;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.skin,
    this.hasReminders = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = goal.daysRemaining;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(skin.borderRadius),
          boxShadow: [
            BoxShadow(
              color: goal.category.color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(skin.borderRadius),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(gradient: goal.category.gradient),
              ),
              if (skin.blur > 0)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: skin.blur, sigmaY: skin.blur),
                  child: Container(color: Colors.transparent),
                ),
              if (skin.overlayColor != null)
                Container(color: skin.overlayColor),
              _decorCircle(Alignment.topRight, 100, 0.12),
              _decorCircle(Alignment.bottomLeft, 80, 0.08),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CategoryBadge(category: goal.category),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasReminders && !goal.isPast)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.notifications_active_rounded,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _CountdownLabel(goal: goal, days: days),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _DaysBadge(goal: goal, days: days, isDark: isDark),
                  ],
                ),
              ),
              if (skin.showBorder)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(skin.borderRadius),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorCircle(AlignmentGeometry alignment, double size, double opacity) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: const Offset(20, -20),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final GoalCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(category.icon, color: Colors.white, size: 26),
    );
  }
}

class _CountdownLabel extends StatelessWidget {
  final Goal goal;
  final int days;

  const _CountdownLabel({required this.goal, required this.days});

  @override
  Widget build(BuildContext context) {
    if (goal.isToday) {
      return Text(
        'Today! 🎉',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w700),
      );
    }
    if (goal.isPast) {
      final absDays = days.abs();
      return Text(
        absDays == 0 ? 'Today' : '$absDays days ago',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
      );
    }
    if (days == 0) {
      final hours = goal.remaining.inHours;
      final minutes = goal.remaining.inMinutes % 60;
      return Text(
        '${hours}h ${minutes}m left',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600),
      );
    }
    return Text(
      '$days days left',
      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
    );
  }
}

class _DaysBadge extends StatelessWidget {
  final Goal goal;
  final int days;
  final bool isDark;

  const _DaysBadge({required this.goal, required this.days, required this.isDark});

  @override
  Widget build(BuildContext context) {
    String label;
    String sub;

    if (goal.isToday) {
      label = '0';
      sub = 'days';
    } else if (goal.isPast) {
      label = '✓';
      sub = 'done';
    } else {
      label = '$days';
      sub = days == 1 ? 'day' : 'days';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            sub,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
