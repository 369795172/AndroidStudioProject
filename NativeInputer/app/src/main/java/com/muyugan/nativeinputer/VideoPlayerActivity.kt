package com.muyugan.nativeinputer

import android.os.Bundle
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader

class VideoPlayerActivity : FragmentActivity() {

    private val engine by lazy {
        FlutterEngine(this).also { engine ->
            // Ensure intent extras are safely accessed, providing defaults if necessary
            val level = intent.getIntExtra("level", 1) // Default to 1 if not found
            val videoId = intent.getStringExtra("videoId") ?: "defaultVideoId" // Provide a default or handle null

            val initialRouteString = "/player?level=$level&videoId=$videoId"
            engine.navigationChannel.setInitialRoute(initialRouteString)

            // Pre-warm Flutter. Ensure applicationContext for broader lifecycle if needed,
            // but 'this' (Activity context) is used in the document.
            FlutterLoader().startInitialization(this) // 预热
            FlutterLoader().ensureInitializationComplete(this, null)

            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // The engine is lazily initialized on its first access here.
        // Ensure Flutter is ready before adding the fragment.
        // The pre-warming is now part of the engine's lazy initialization block.

        // Re-derive the initial route for clarity and ensure consistency
        val level = intent.getIntExtra("level", 1)
        val videoId = intent.getStringExtra("videoId") ?: "defaultVideoId"
        val currentInitialRoute = "/player?level=$level&videoId=$videoId"

        // Create a FlutterFragment with a new engine, configured with the initial route
        val flutterFragment = FlutterFragment
            .withNewEngine()
            .initialRoute(currentInitialRoute) // Use the re-derived route string
            // .renderMode(RenderMode.surface) // Optional: if you face rendering issues or need specific mode
            // .transparencyMode(TransparencyMode.transparent) // Optional: for transparency
            .shouldAttachEngineToActivity(true) // Usually true to forward Android lifecycle events
            .build<FlutterFragment>()

        supportFragmentManager
            .beginTransaction()
            .replace(android.R.id.content, flutterFragment)
            .commit()
    }

    // The document's snippet for VideoPlayerActivity does not include explicit engine destruction.
    // For a cached engine, its lifecycle is managed by FlutterEngineCache or by how it's stored.
    // If this activity is the sole user of this specific lazily-created engine instance
    // AND it's not intended to be cached globally beyond this activity's lifecycle,
    // you might consider cleaning it up in onDestroy.
    // override fun onDestroy() {
    //     super.onDestroy()
    //     // If the engine was created by this activity and not intended for wider caching:
    //     // engine.destroy() // This would be needed if not using a global cache and engine is specific to this activity.
    // }
}

// Removed FlutterEngineCacheManager as the document's snippet implies a simpler, activity-local lazy engine management
// for the purpose of FlutterFragment.withCachedEngine.