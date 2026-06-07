package com.ucydigital.examtimer.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.glance.appwidget.cornerRadius
import com.ucydigital.examtimer.MainActivity
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class SmallExamWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val configJson = prefs.getString("widget_config", null)
        val examsJson = prefs.getString("selected_exams_json", null)
        
        provideContent {
            SmallWidgetContent(configJson, examsJson)
        }
    }

    @Composable
    private fun SmallWidgetContent(configJson: String?, examsJson: String?) {
        var bgColor = Color(0xFF121212)
        var textColor = Color(0xFFF5F5F5)
        var opacity = 0.4f
        var selectedExamId: String? = null

        configJson?.let {
            try {
                val json = JSONObject(it)
                bgColor = parseHexColor(json.getString("bg_color"))
                textColor = parseHexColor(json.getString("text_color"))
                opacity = json.getDouble("opacity").toFloat()
                selectedExamId = json.optString("selected_exam_id", null)
            } catch (e: Exception) {}
        }

        var examTitle = "Sınav"
        var daysLeft = "0"
        var hoursLeft = "0"

        examsJson?.let {
            try {
                val examsArray = org.json.JSONArray(it)
                if (examsArray.length() > 0) {
                    var found = false
                    for (i in 0 until examsArray.length()) {
                        val exam = examsArray.getJSONObject(i)
                        val id = exam.getString("id")
                        
                        if (selectedExamId == null || selectedExamId == "" || id == selectedExamId) {
                            examTitle = exam.optString("shortTitle", "Sınav")
                            if (examTitle == "Sınav" || examTitle == "") {
                                examTitle = exam.getString("title").split("\n").first()
                            }
                            
                            val dateStr = exam.getString("date")
                            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
                            val examDate = sdf.parse(dateStr)
                            
                            examDate?.let { date ->
                                val diff = date.time - System.currentTimeMillis()
                                if (diff > 0) {
                                    val days = diff / (1000 * 60 * 60 * 24)
                                    val hours = (diff / (1000 * 60 * 60)) % 24
                                    
                                    daysLeft = days.toString()
                                    hoursLeft = hours.toString()
                                }
                            }
                            found = true
                            break
                        }
                    }
                    if (!found) {
                        // Fallback to first exam if selected not found
                        val exam = examsArray.getJSONObject(0)
                        examTitle = exam.optString("shortTitle", "Sınav")
                        val dateStr = exam.getString("date")
                        val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
                        val examDate = sdf.parse(dateStr)
                        examDate?.let { date ->
                            val diff = date.time - System.currentTimeMillis()
                            val days = diff / (1000 * 60 * 60 * 24)
                            val hours = (diff / (1000 * 60 * 60)) % 24
                            daysLeft = days.coerceAtLeast(0).toString()
                            hoursLeft = hours.coerceAtLeast(0).toString()
                        }
                    }
                }
            } catch (e: Exception) {}
        }

        val finalBgColor = bgColor.copy(alpha = opacity)

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(finalBgColor)
                .padding(16.dp)
                .cornerRadius(28.dp)
                .clickable(actionStartActivity<MainActivity>()),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = examTitle.uppercase(),
                style = TextStyle(
                    color = ColorProvider(textColor),
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                ),
                maxLines = 1
            )

            Spacer(modifier = GlanceModifier.height(8.dp))

            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                TimeColumn(daysLeft, "GÜN", textColor)
                TimeColumn(hoursLeft, "SAAT", textColor)
            }
        }
    }

    @Composable
    private fun TimeColumn(value: String, label: String, color: Color) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = GlanceModifier.padding(horizontal = 8.dp)
        ) {
            Text(
                text = value,
                style = TextStyle(
                    color = ColorProvider(color),
                    fontWeight = FontWeight.Bold,
                    fontSize = 28.sp
                )
            )
            Text(
                text = label,
                style = TextStyle(
                    color = ColorProvider(color.copy(alpha = 0.6f)),
                    fontSize = 9.sp
                )
            )
        }
    }

    private fun parseHexColor(hex: String): Color {
        return try {
            Color(android.graphics.Color.parseColor(hex))
        } catch (e: Exception) {
            Color.White
        }
    }
}
