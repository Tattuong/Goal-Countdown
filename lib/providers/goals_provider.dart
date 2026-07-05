import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/storage_service.dart';
import '../core/services/widget_service.dart';
import '../models/goal.dart';

class GoalsProvider extends ChangeNotifier {
  static const _goalsKey = 'gc_goals';
  static const _addGoalRewardDateKey = 'gc_add_goal_reward_date';
  static const _addGoalRewardCountKey = 'gc_add_goal_reward_count';
  static const _shareRewardDateKey = 'gc_share_reward_date';
  static const _shareRewardCountKey = 'gc_share_reward_count';

  List<Goal> _goals = [];
  bool _loaded = false;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoaded => _loaded;

  List<Goal> get sortedGoals {
    final upcoming = _goals.where((g) => !g.isPast).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    final past = _goals.where((g) => g.isPast).toList()
      ..sort((a, b) => b.targetDate.compareTo(a.targetDate));
    return [...upcoming, ...past];
  }

  Goal? get nextUpcomingGoal {
    final upcoming = _goals.where((g) => !g.isPast).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return upcoming.first;
  }

  int get goalCount => _goals.length;

  bool canAddGoal({required bool hasUnlimitedGoals}) {
    if (hasUnlimitedGoals) return true;
    return _goals.length < IapConstants.freeGoalLimit;
  }

  Future<void> load() async {
    try {
      final raw = await StorageService.instance.getString(_goalsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _goals = list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('GoalsProvider load error: $e');
      _goals = [];
    }
    _loaded = true;
    notifyListeners();
  }

  Future<bool> addGoal(Goal goal, {required bool hasUnlimitedGoals}) async {
    if (!canAddGoal(hasUnlimitedGoals: hasUnlimitedGoals)) return false;
    _goals.add(goal);
    await _save();
    await _syncWidget();
    notifyListeners();
    return true;
  }

  Future<void> updateGoal(Goal goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx < 0) return;
    _goals[idx] = goal;
    await _save();
    await _syncWidget();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _save();
    await _syncWidget();
    notifyListeners();
  }

  Future<bool> rewardForAddGoal() async {
    final today = _dateKey(DateTime.now());
    final savedDate = await StorageService.instance.getString(_addGoalRewardDateKey);
    var count = await StorageService.instance.getInt(_addGoalRewardCountKey) ?? 0;

    if (savedDate != today) {
      count = 0;
      await StorageService.instance.saveString(_addGoalRewardDateKey, today);
    }

    if (count >= IapConstants.maxAddGoalRewardsPerDay) return false;

    count++;
    await StorageService.instance.saveInt(_addGoalRewardCountKey, count);
    return true;
  }

  Future<bool> rewardForShare() async {
    final today = _dateKey(DateTime.now());
    final savedDate = await StorageService.instance.getString(_shareRewardDateKey);
    var count = await StorageService.instance.getInt(_shareRewardCountKey) ?? 0;

    if (savedDate != today) {
      count = 0;
      await StorageService.instance.saveString(_shareRewardDateKey, today);
    }

    if (count >= IapConstants.maxShareRewardsPerDay) return false;

    count++;
    await StorageService.instance.saveInt(_shareRewardCountKey, count);
    return true;
  }

  Future<void> syncWidget({String widgetStyle = 'default'}) async {
    await _syncWidget(widgetStyle: widgetStyle);
  }

  String exportGoalsJson() {
    final buffer = StringBuffer('[\n');
    for (var i = 0; i < _goals.length; i++) {
      final g = _goals[i];
      buffer.write(
        '  {"id":"${g.id}","title":"${g.title.replaceAll('"', '\\"')}","targetDate":"${g.targetDate.toIso8601String()}","category":"${g.category.name}","daysRemaining":${g.daysRemaining}}',
      );
      if (i < _goals.length - 1) buffer.write(',');
      buffer.write('\n');
    }
    buffer.write(']');
    return buffer.toString();
  }

  Future<void> _save() async {
    try {
      final list = _goals.map((g) => g.toJson()).toList();
      await StorageService.instance.saveString(_goalsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('GoalsProvider save error: $e');
    }
  }

  Future<void> _syncWidget({String widgetStyle = 'default'}) async {
    final next = nextUpcomingGoal;
    if (next != null) {
      await WidgetService.updateGoalWidget(
        goalTitle: next.title,
        daysRemaining: next.daysRemaining,
        widgetStyle: widgetStyle,
      );
    } else {
      await WidgetService.clearWidget();
    }
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
