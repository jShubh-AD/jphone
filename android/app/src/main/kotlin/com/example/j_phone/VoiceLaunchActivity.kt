package com.example.j_phone

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle

class VoiceLaunchActivity : Activity() {

    companion object {
        const val CHATGPT_PACKAGE = "com.openai.chatgpt"
        const val VOICE_ACTIVITY = "com.openai.voice.assistant.AssistantActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val pm = packageManager
        var launched = false

        // 1. Try ACTION_ASSIST targeted at ChatGPT (System Assistant trigger)
        try {
            val assistIntent = Intent(Intent.ACTION_ASSIST).apply {
                setPackage(CHATGPT_PACKAGE)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            if (assistIntent.resolveActivity(pm) != null) {
                startActivity(assistIntent)
                launched = true
            }
        } catch (_: Exception) {}

        // 2. Try direct AssistantActivity component
        if (!launched) {
            try {
                val directIntent = Intent().apply {
                    component = ComponentName(CHATGPT_PACKAGE, VOICE_ACTIVITY)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(directIntent)
                launched = true
            } catch (_: Exception) {}
        }

        // 3. Try VOICE_COMMAND
        if (!launched) {
            try {
                val voiceCommandIntent = Intent(Intent.ACTION_VOICE_COMMAND).apply {
                    setPackage(CHATGPT_PACKAGE)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                if (voiceCommandIntent.resolveActivity(pm) != null) {
                    startActivity(voiceCommandIntent)
                    launched = true
                }
            } catch (_: Exception) {}
        }

        // 4. Fallback to clean app launch
        if (!launched) {
            val launchIntent = pm.getLaunchIntentForPackage(CHATGPT_PACKAGE)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launchIntent)
            }
        }

        finish()
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            overrideActivityTransition(OVERRIDE_TRANSITION_CLOSE, 0, 0)
        } else {
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)
        }
    }
}

