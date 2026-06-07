package com.ucydigital.examtimer.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.*
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.compose.ui.graphics.Color
import com.ucydigital.examtimer.MainActivity
import com.ucydigital.examtimer.R

class MediumMotivationalWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val quote = prefs.getString("motivation_quote", "Zorluklar, başarının değerini artıran süslerdir.") ?: "Zorluklar, başarının değerini artıran süslerdir."

        provideContent {
            MediumWidgetContent(quote)
        }
    }

    @Composable
    private fun MediumWidgetContent(quote: String) {
        val backgroundColor = Color(0xFF121212)
        val primaryColor = Color(0xFFC7B8FF)
        val textColor = Color(0xFFF5F5F5)

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(backgroundColor)
                .padding(16.dp)
                .cornerRadius(24.dp)
                .clickable(actionStartActivity<MainActivity>())
        ) {
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.Start,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Image(
                    provider = ImageProvider(R.mipmap.ic_launcher),
                    contentDescription = "Timer",
                    modifier = GlanceModifier.size(16.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(primaryColor))
                )
                Spacer(modifier = GlanceModifier.width(8.dp))
                Text(
                    text = "GÜNÜN SÖZÜ",
                    style = TextStyle(
                        color = ColorProvider(primaryColor),
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                )
            }

            Spacer(modifier = GlanceModifier.height(12.dp))

            Text(
                text = "Motivasyon",
                style = TextStyle(
                    color = ColorProvider(textColor),
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp
                )
            )

            Spacer(modifier = GlanceModifier.height(16.dp))

            Box(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .background(Color(0xFF1E1E1E))
                    .padding(12.dp)
                    .cornerRadius(16.dp)
            ) {
                Text(
                    text = "\"$quote\"",
                    style = TextStyle(
                        color = ColorProvider(textColor.copy(alpha = 0.9f)),
                        fontSize = 13.sp,
                        fontStyle = androidx.glance.text.FontStyle.Italic
                    )
                )
            }
        }
    }
}
