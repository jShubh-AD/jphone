package com.example.j_phone

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class ChatGptWidgetProvider : AppWidgetProvider() {

    companion object {
        const val CHATGPT_PACKAGE = "com.openai.chatgpt"
        const val CHATGPT_WEB = "https://chatgpt.com"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_CONFIGURATION_CHANGED) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, ChatGptWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.chatgpt_widget)

        // 1. Tapping Chat Bar opens Option B Quick Prompt
        val quickPromptIntent = Intent(context, QuickPromptActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val quickPromptPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId * 10 + 1,
            quickPromptIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_chat_bar, quickPromptPendingIntent)

        // 2. Tapping Logo opens ChatGPT App directly
        val logoIntent = createSafeChatGptLaunchIntent(context)
        val logoPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId * 10 + 2,
            logoIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.iv_chatgpt_logo, logoPendingIntent)

        // 3. Tapping Voice Mode (Headphones) opens VoiceLaunchActivity
        val voiceIntent = Intent(context, VoiceLaunchActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val voicePendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId * 10 + 3,
            voiceIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_voice_mode, voicePendingIntent)

        // 4. Tapping Microphone also triggers VoiceLaunchActivity
        views.setOnClickPendingIntent(R.id.btn_mic, voicePendingIntent)

        // 5. Tapping History opens the QuickHistoryActivity floating drawer
        val historyIntent = Intent(context, QuickHistoryActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val historyPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId * 10 + 5,
            historyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_history, historyPendingIntent)

        // Update the widget via Android AppWidgetManager
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun createSafeChatGptLaunchIntent(context: Context): Intent {
        val pm = context.packageManager
        val launchIntent = pm.getLaunchIntentForPackage(CHATGPT_PACKAGE)
        return launchIntent ?: Intent(Intent.ACTION_VIEW, Uri.parse(CHATGPT_WEB)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }
}
