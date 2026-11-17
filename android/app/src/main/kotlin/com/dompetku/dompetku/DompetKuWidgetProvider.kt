package com.dompetku.dompetku

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DompetKuWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.dompetku_widget_layout).apply {
                // Open App on Widget Click
                val pendingIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // Date
                val todayDate = widgetData.getString("today_date", null) ?: "Hari Ini"
                setTextViewText(R.id.widget_date, todayDate)

                // Today Income & Expense
                val income = widgetData.getString("today_income", null) ?: "Rp 0"
                val expense = widgetData.getString("today_expense", null) ?: "Rp 0"
                setTextViewText(R.id.widget_today_income, income)
                setTextViewText(R.id.widget_today_expense, expense)

                // Transactions
                val hasTx = widgetData.getBoolean("has_tx", false)
                if (hasTx) {
                    setViewVisibility(R.id.widget_tx_empty, View.GONE)

                    // Transaction 1
                    val tx1Title = widgetData.getString("tx1_title", null)
                    if (tx1Title != null) {
                        setViewVisibility(R.id.widget_tx_1, View.VISIBLE)
                        setTextViewText(R.id.widget_tx_1_title, tx1Title)
                        setTextViewText(
                            R.id.widget_tx_1_date,
                            widgetData.getString("tx1_date", "") ?: ""
                        )
                        val tx1Amount = widgetData.getString("tx1_amount", "") ?: ""
                        setTextViewText(R.id.widget_tx_1_amount, tx1Amount)
                        val tx1IsIncome = widgetData.getBoolean("tx1_is_income", false)
                        setTextColor(
                            R.id.widget_tx_1_amount,
                            if (tx1IsIncome) Color.parseColor("#15803D") else Color.parseColor("#DC2626")
                        )
                    } else {
                        setViewVisibility(R.id.widget_tx_1, View.GONE)
                    }

                    // Transaction 2
                    val tx2Title = widgetData.getString("tx2_title", null)
                    if (tx2Title != null) {
                        setViewVisibility(R.id.widget_tx_divider_1, View.VISIBLE)
                        setViewVisibility(R.id.widget_tx_2, View.VISIBLE)
                        setTextViewText(R.id.widget_tx_2_title, tx2Title)
                        setTextViewText(
                            R.id.widget_tx_2_date,
                            widgetData.getString("tx2_date", "") ?: ""
                        )
                        val tx2Amount = widgetData.getString("tx2_amount", "") ?: ""
                        setTextViewText(R.id.widget_tx_2_amount, tx2Amount)
                        val tx2IsIncome = widgetData.getBoolean("tx2_is_income", false)
                        setTextColor(
                            R.id.widget_tx_2_amount,
                            if (tx2IsIncome) Color.parseColor("#15803D") else Color.parseColor("#DC2626")
                        )
                    } else {
                        setViewVisibility(R.id.widget_tx_divider_1, View.GONE)
                        setViewVisibility(R.id.widget_tx_2, View.GONE)
                    }

                    // Transaction 3
                    val tx3Title = widgetData.getString("tx3_title", null)
                    if (tx3Title != null) {
                        setViewVisibility(R.id.widget_tx_divider_2, View.VISIBLE)
                        setViewVisibility(R.id.widget_tx_3, View.VISIBLE)
                        setTextViewText(R.id.widget_tx_3_title, tx3Title)
                        setTextViewText(
                            R.id.widget_tx_3_date,
                            widgetData.getString("tx3_date", "") ?: ""
                        )
                        val tx3Amount = widgetData.getString("tx3_amount", "") ?: ""
                        setTextViewText(R.id.widget_tx_3_amount, tx3Amount)
                        val tx3IsIncome = widgetData.getBoolean("tx3_is_income", false)
                        setTextColor(
                            R.id.widget_tx_3_amount,
                            if (tx3IsIncome) Color.parseColor("#15803D") else Color.parseColor("#DC2626")
                        )
                    } else {
                        setViewVisibility(R.id.widget_tx_divider_2, View.GONE)
                        setViewVisibility(R.id.widget_tx_3, View.GONE)
                    }

                    // Transaction 4
                    val tx4Title = widgetData.getString("tx4_title", null)
                    if (tx4Title != null) {
                        setViewVisibility(R.id.widget_tx_divider_3, View.VISIBLE)
                        setViewVisibility(R.id.widget_tx_4, View.VISIBLE)
                        setTextViewText(R.id.widget_tx_4_title, tx4Title)
                        setTextViewText(
                            R.id.widget_tx_4_date,
                            widgetData.getString("tx4_date", "") ?: ""
                        )
                        val tx4Amount = widgetData.getString("tx4_amount", "") ?: ""
                        setTextViewText(R.id.widget_tx_4_amount, tx4Amount)
                        val tx4IsIncome = widgetData.getBoolean("tx4_is_income", false)
                        setTextColor(
                            R.id.widget_tx_4_amount,
                            if (tx4IsIncome) Color.parseColor("#15803D") else Color.parseColor("#DC2626")
                        )
                    } else {
                        setViewVisibility(R.id.widget_tx_divider_3, View.GONE)
                        setViewVisibility(R.id.widget_tx_4, View.GONE)
                    }
                } else {
                    setViewVisibility(R.id.widget_tx_empty, View.VISIBLE)
                    setViewVisibility(R.id.widget_tx_1, View.GONE)
                    setViewVisibility(R.id.widget_tx_divider_1, View.GONE)
                    setViewVisibility(R.id.widget_tx_2, View.GONE)
                    setViewVisibility(R.id.widget_tx_divider_2, View.GONE)
                    setViewVisibility(R.id.widget_tx_3, View.GONE)
                    setViewVisibility(R.id.widget_tx_divider_3, View.GONE)
                    setViewVisibility(R.id.widget_tx_4, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
