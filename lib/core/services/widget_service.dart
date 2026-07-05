import 'package:home_widget/home_widget.dart';

class WidgetService {
  WidgetService._();

  static const _appGroupId = 'group.com.goalcountdownmng.goalcountdown';
  static const _goalTitleKey = 'goal_title';
  static const _goalDaysKey = 'goal_days';
  static const _androidWidgetName = 'GoalWidgetProvider';

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (_) {}
  }

  static Future<void> updateGoalWidget({
    required String goalTitle,
    required int daysRemaining,
    String widgetStyle = 'default',
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(_goalTitleKey, goalTitle);
      await HomeWidget.saveWidgetData<int>(_goalDaysKey, daysRemaining);
      await HomeWidget.saveWidgetData<String>('widget_style', widgetStyle);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: 'GoalWidget',
      );
    } catch (_) {}
  }

  static Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(_goalTitleKey, '');
      await HomeWidget.saveWidgetData<int>(_goalDaysKey, 0);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: 'GoalWidget',
      );
    } catch (_) {}
  }
}
