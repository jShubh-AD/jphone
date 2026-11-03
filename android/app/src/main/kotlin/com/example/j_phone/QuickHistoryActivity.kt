package com.example.j_phone

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.TextView

class QuickHistoryActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_quick_history)

        val rootOverlay = findViewById<View>(R.id.fl_history_root)
        val historyCard = findViewById<View>(R.id.ll_history_card)
        val tvEmpty = findViewById<TextView>(R.id.tv_empty_history)
        val lvPrompts = findViewById<ListView>(R.id.lv_history_prompts)
        val btnOpenApp = findViewById<TextView>(R.id.btn_open_chatgpt)

        rootOverlay.setOnClickListener {
            finishWithNoAnimation()
        }

        historyCard.setOnClickListener { /* Consume click */ }

        btnOpenApp.setOnClickListener {
            val launchIntent = packageManager.getLaunchIntentForPackage("com.openai.chatgpt")
                ?: Intent(Intent.ACTION_VIEW, Uri.parse("https://chatgpt.com"))
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(launchIntent)
            finishWithNoAnimation()
        }

        val prompts = QuickPromptActivity.getPrompts(this)

        if (prompts.isEmpty()) {
            tvEmpty.visibility = View.VISIBLE
            lvPrompts.visibility = View.GONE
        } else {
            tvEmpty.visibility = View.GONE
            lvPrompts.visibility = View.VISIBLE

            val adapter = object : ArrayAdapter<String>(this, R.layout.item_quick_history, prompts) {
                override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
                    val view = convertView ?: LayoutInflater.from(context)
                        .inflate(R.layout.item_quick_history, parent, false)
                    val text = getItem(position) ?: ""
                    val tv = view.findViewById<TextView>(R.id.tv_history_item_text)
                    tv.text = text
                    return view
                }
            }

            lvPrompts.adapter = adapter
            lvPrompts.setOnItemClickListener { _, _, position, _ ->
                val selectedPrompt = prompts[position]
                launchPromptInChatGpt(selectedPrompt)
            }
        }
    }

    private fun launchPromptInChatGpt(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
        val clip = ClipData.newPlainText("ChatGPT Prompt", text)
        clipboard?.setPrimaryClip(clip)

        val encodedPrompt = Uri.encode(text)
        val chatGptUrl = "https://chatgpt.com/?q=$encodedPrompt"
        val viewIntent = Intent(Intent.ACTION_VIEW, Uri.parse(chatGptUrl)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        val appIntent = Intent(Intent.ACTION_VIEW, Uri.parse(chatGptUrl)).apply {
            setPackage("com.openai.chatgpt")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        if (appIntent.resolveActivity(packageManager) != null) {
            try {
                startActivity(appIntent)
            } catch (e: Exception) {
                startActivity(viewIntent)
            }
        } else {
            startActivity(viewIntent)
        }

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

