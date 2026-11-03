package com.example.j_phone

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.ImageButton

class QuickPromptActivity : Activity() {

    companion object {
        const val PREFS_NAME = "chatgpt_widget_prefs"
        const val KEY_HISTORY = "recent_prompts_list"

        fun savePrompt(context: Context, prompt: String) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val raw = prefs.getString(KEY_HISTORY, "") ?: ""
            val list = if (raw.isEmpty()) mutableListOf() else raw.split("\u001F").toMutableList()
            list.remove(prompt)
            list.add(0, prompt)
            val trimmed = list.take(20)
            prefs.edit().putString(KEY_HISTORY, trimmed.joinToString("\u001F")).apply()
        }

        fun getPrompts(context: Context): List<String> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val raw = prefs.getString(KEY_HISTORY, "") ?: ""
            if (raw.isEmpty()) return emptyList()
            return raw.split("\u001F").filter { it.isNotBlank() }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_quick_prompt)

        val rootOverlay = findViewById<View>(R.id.fl_root_overlay)
        val promptCard = findViewById<View>(R.id.ll_prompt_card)
        val etPrompt = findViewById<EditText>(R.id.et_quick_prompt)
        val btnSend = findViewById<ImageButton>(R.id.btn_send_prompt)

        rootOverlay.setOnClickListener {
            hideKeyboardAndFinish(etPrompt)
        }

        promptCard.setOnClickListener { /* Consume click */ }

        btnSend.setOnClickListener {
            submitPrompt(etPrompt.text.toString().trim())
        }

        etPrompt.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEND || actionId == EditorInfo.IME_ACTION_DONE) {
                submitPrompt(etPrompt.text.toString().trim())
                true
            } else {
                false
            }
        }

        etPrompt.requestFocus()
        etPrompt.postDelayed({
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
            imm?.showSoftInput(etPrompt, InputMethodManager.SHOW_IMPLICIT)
        }, 120)
    }

    private fun submitPrompt(text: String) {
        if (text.isNotEmpty()) {
            // 1. Save to local widget prompt history
            savePrompt(this, text)

            // 2. Copy to clipboard
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            val clip = ClipData.newPlainText("ChatGPT Prompt", text)
            clipboard?.setPrimaryClip(clip)

            // 3. Launch via official App Link
            val encodedPrompt = Uri.encode(text)
            val chatGptUrl = "https://chatgpt.com/?q=$encodedPrompt"
            val viewIntent = Intent(Intent.ACTION_VIEW, Uri.parse(chatGptUrl)).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            val pm = packageManager
            val appIntent = Intent(Intent.ACTION_VIEW, Uri.parse(chatGptUrl)).apply {
                setPackage("com.openai.chatgpt")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (appIntent.resolveActivity(pm) != null) {
                try {
                    startActivity(appIntent)
                } catch (e: Exception) {
                    startActivity(viewIntent)
                }
            } else {
                startActivity(viewIntent)
            }
        }

        finishWithNoAnimation()
    }

    private fun hideKeyboardAndFinish(view: View) {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.hideSoftInputFromWindow(view.windowToken, 0)
        finishWithNoAnimation()
    }

    private fun finishWithNoAnimation() {
        finish()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            overrideActivityTransition(OVERRIDE_TRANSITION_CLOSE, 0, 0)
        } else {
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)
        }
    }
}
