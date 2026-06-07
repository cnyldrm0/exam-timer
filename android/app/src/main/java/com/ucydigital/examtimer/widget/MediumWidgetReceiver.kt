package com.ucydigital.examtimer.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class MediumWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = MediumMotivationalWidget()

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // Schedule background updates when the first widget instance is placed
        WidgetUpdateWorker.schedule(context)
    }
}
