package com.muyugan.nativeinputer

import android.os.Bundle
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterFragment

class VideoPlayerActivity : FragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get intent parameters
        val level = intent.getIntExtra("level", 1)
        val videoId = intent.getStringExtra("videoId") ?: "video2"
        
        // Log the parameters for debugging
        println("[VideoPlayerActivity] Starting with level=$level, videoId=$videoId")
        
        // Use a simpler route format that Flutter can handle better
        val initialRoute = "/player?videoId=$videoId&level=$level"
        println("[VideoPlayerActivity] Setting initialRoute: $initialRoute")

        // Create FlutterFragment with direct route to player
        val flutterFragment = FlutterFragment
            .withNewEngine()
            .initialRoute(initialRoute)
            .shouldAttachEngineToActivity(true)
            .build<FlutterFragment>()

        // Add fragment to activity
        supportFragmentManager
            .beginTransaction()
            .replace(android.R.id.content, flutterFragment)
            .commit()
    }
}

// Removed FlutterEngineCacheManager as the document's snippet implies a simpler, activity-local lazy engine management
// for the purpose of FlutterFragment.withCachedEngine.