package com.goalcountdownmng.goalcountdown

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class GoalWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val widgetStyle = widgetData.getString("widget_style", "default") ?: "default"

        appWidgetIds.forEach { widgetId ->
            val layoutId = when (widgetStyle) {
                "dark" -> R.layout.goal_widget_dark
                "minimal" -> R.layout.goal_widget_minimal
                else -> R.layout.goal_widget
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                val title = widgetData.getString("goal_title", "")
                val days = widgetData.getInt("goal_days", 0)
                if (title.isNullOrEmpty()) {
                    setTextViewText(R.id.widget_goal_title, "Goal Countdown")
                    setTextViewText(R.id.widget_goal_days, "Add a goal")
                } else {
                    setTextViewText(R.id.widget_goal_title, title)
                    val daysText = when {
                        days == 0 -> "Today! 🎉"
                        days < 0 -> "${-days} days ago"
                        days == 1 -> "1 day left"
                        else -> "$days days left"
                    }
                    setTextViewText(R.id.widget_goal_days, daysText)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
