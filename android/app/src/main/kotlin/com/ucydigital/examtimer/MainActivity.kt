package com.ucydigital.examtimer

import android.content.Context
import androidx.glance.appwidget.updateAll
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import com.ucydigital.examtimer.widget.SmallExamWidget
import com.ucydigital.examtimer.widget.MediumMotivationalWidget
import com.ucydigital.examtimer.widget.WidgetUpdateWorker

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ucydigital.sinavsayac/exam_sync"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Start background worker when app starts
        scheduleWidgetUpdates()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "syncExams") {
                val examsJson = call.argument<String>("examsJson")
                if (examsJson != null) {
                    saveExamsToNative(examsJson)
                    updateWidgets()
                    result.success(true)
                } else {
                    result.error("INVALID_DATA", "Exams data is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scheduleWidgetUpdates() {
        WidgetUpdateWorker.schedule(this)
    }

    private fun saveExamsToNative(json: String) {
        val homeWidgetPrefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        homeWidgetPrefs.edit().putString("selected_exams_json", json).apply()

        val sharedPref = getSharedPreferences("exam_prefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("selected_exams_json", json)
            apply()
        }
    }

    private fun updateWidgets() {
        MainScope().launch {
            SmallExamWidget().updateAll(this@MainActivity)
            MediumMotivationalWidget().updateAll(this@MainActivity)
        }
    }
}
