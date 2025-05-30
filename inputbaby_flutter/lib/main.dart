import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome if used here
import 'package:video_player/video_player.dart'; // Assuming this package

// --- Placeholder/Stub for LocalStore (Step 6) ---
class LocalStore {
  static Future<void> saveProgress(Duration p) async {
    // print("LocalStore: saveProgress $p");
    // In a real app, use SharedPreferences or similar
  }

  static VideoPlaybackState? resume(int level) {
    // print("LocalStore: resume for level $level");
    // In a real app, load from SharedPreferences
    // Return null if no resume data, or a VideoPlaybackState
    return null; // Placeholder
  }
}

// --- Placeholder/Stub for Video data and related functions ---
class VideoData {
  final String id;
  final String title;
  final String assetPath; // Or URL

  VideoData({required this.id, required this.title, required this.assetPath});
}

List<VideoData> videosOf(int level) {
  // print("videosOf: level $level");
  // Placeholder: return some dummy video data
  return List.generate(
    6,
    (index) => VideoData(
      id: "vid_${level}_$index",
      title: "Video $index (Level $level)",
      assetPath: "assets/videos/sample.mp4", // Make sure you have a sample video here
    ),
  );
}

String findAsset(String videoId) {
  // print("findAsset: videoId $videoId");
  // Placeholder: In a real app, map videoId to actual asset path or URL
  // For now, assume all videos use a default placeholder asset
  final foundVideo = videosOf(1).firstWhere((v) => v.id == videoId, orElse: () => videosOf(1).first);
  return foundVideo.assetPath; // e.g., "assets/videos/sample.mp4"
}

// --- Placeholder/Stub for ResumeBanner Widget ---
class ResumeBanner extends StatelessWidget {
  final VideoPlaybackState lastPlayback;
  const ResumeBanner(this.lastPlayback, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey.shade100,
      child: Text("Resume: ${lastPlayback.videoId} at ${lastPlayback.position.inSeconds}s"),
    );
  }
}

// --- Placeholder/Stub for VideoPlaybackState (used by ResumeBanner) ---
class VideoPlaybackState {
  final String videoId;
  final Duration position;
  VideoPlaybackState({required this.videoId, required this.position});
}


// --- Placeholder/Stub for VideoTile Widget ---
class VideoTile extends StatelessWidget {
  final VideoData video;
  const VideoTile(this.video, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/player',
            arguments: Uri(queryParameters: {'videoId': video.id, 'level': '1'}).toString(), // Simulate route string from native
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 48),
            const SizedBox(height: 8),
            Text(video.title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// --- Placeholder/Stub for QuizManager ---
class QuizManager {
  static bool shouldShow() {
    // print("QuizManager: shouldShow");
    return false; // Placeholder
  }
}

// --- Placeholder/Stub for InteractiveQuizOverlay Widget ---
class InteractiveQuizOverlay extends StatelessWidget {
  const InteractiveQuizOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Interactive Quiz Area (Placeholder)"),
        ),
      ),
    );
  }
}

// --- Placeholder/Stub for RewardBloc and RewardIndicator ---
class RewardBloc { // Simple placeholder, not a full BLoC
  static int get state {
    // print("RewardBloc: get state");
    return 75; // Placeholder progress
  }
}

class RewardIndicator extends StatelessWidget {
  final int progress;
  const RewardIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text("Reward: $progress%"));
  }
}


// --- Main Application ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // As per doc: "要上 60 FPS，记得 SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky) + Impeller。"
  // Applying immersive mode here.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const InputBabyApp());
}

class InputBabyApp extends StatelessWidget {
  const InputBabyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          // The initialRoute from native side will be like "/player?level=1&videoId=someId"
          // Or, if Flutter starts "cold" without a specific route from native, it might use '/'
          '/': (_) => const VideoHomePage(), // Default route if no specific path is given
          '/player': (c) {
            // Extract params for VideoPlayerPage if needed directly,
            // but VideoPlayerPage itself handles ModalRoute.of(context)!.settings.name!
            return const VideoPlayerPage();
          },
        },
        // The initial route is typically set by the native side via FlutterEngine.navigationChannel.setInitialRoute()
        // If Flutter is launched independently or that native call isn't made, this '/' will be used.
        initialRoute: '/',
      );
}

/// 1️⃣ 网格主页 + 续播横幅
class VideoHomePage extends StatelessWidget {
  const VideoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // The document mentions: final level = ModalRoute.of(context)!.settings.arguments as int? ?? 1;
    // This implies arguments are passed to '/'. If coming from native with initialRoute like "/player?...",
    // this page might not get arguments directly unless native targets '/' with args.
    // For simplicity, let's assume a default level or one derived differently if on home page.
    final int level = 1; // Placeholder, adapt if arguments are passed to '/'
    final VideoPlaybackState? last = LocalStore.resume(level);

    return Scaffold(
      appBar: AppBar(title: Text("Videos - Level $level"), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          if (last != null) ResumeBanner(last),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 16 / 9, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: videosOf(level).length,
              itemBuilder: (_, i) => VideoTile(videosOf(level)[i]),
            ),
          )
        ],
      ),
    );
  }
}

/// 2️⃣ 播放器 Stack + 手势
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool controlsVisible = true;
  late VideoPlayerController ctrl;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // Ensure context is available before using ModalRoute
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  void _initializePlayer() {
    if (!mounted) return; // Ensure widget is still in the tree

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == null) {
      // print("Error: Route name is null. Cannot initialize player.");
      if (mounted) setState(() => _isError = true);
      return;
    }

    final Uri args = Uri.parse(routeName); // e.g. /player?level=1&videoId=someId
    final videoId = args.queryParameters['videoId'];
    final level = args.queryParameters['level']; // level might be used for other logic

    // ---- TEST LOGGING ----
    print("[VideoPlayerPage] Received route: $routeName");
    print("[VideoPlayerPage] Extracted videoId: $videoId, level: $level");
    // ---- END TEST LOGGING ----

    if (videoId == null) {
      // print("Error: videoId is null. Cannot initialize player.");
      if (mounted) setState(() => _isError = true);
      return;
    }
    
    final assetPath = findAsset(videoId);

    // ctrl = VideoPlayerController.asset(findAsset(args.queryParameters['videoId']!))
    ctrl = VideoPlayerController.asset(assetPath) // Use the resolved assetPath
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          ctrl.play();
          ctrl.addListener(_tick);
          _autoHide();
        });
      }).catchError((error) {
        // print("Error initializing video player: $error");
        if (mounted) setState(() => _isError = true);
      });
  }

  void _tick() {
    if (!mounted || !ctrl.value.isInitialized) return;
    // 连播 + 断点保存
    if (ctrl.value.position >= ctrl.value.duration && ctrl.value.duration > Duration.zero) {
      // Check duration > zero to prevent issues with uninitialized/empty videos
       _playNext();
    }
    LocalStore.saveProgress(ctrl.value.position);
    if (mounted) setState(() {}); // To update UI based on playback, if any part depends on it
  }

  void _playNext() {
    // print("_playNext: Placeholder logic");
    // Placeholder: Implement logic to play the next video
    // For now, just pop or replay
    if (mounted) {
       // Navigator.pop(context); // Or find next video and re-initialize controller
    }
  }

  void _autoHide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && controlsVisible) setState(() => controlsVisible = false);
    });
  }

  @override
  void dispose() {
    ctrl.removeListener(_tick);
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isError || !ctrl.value.isInitialized) {
      return const Scaffold(body: Center(child: Text("Error loading video. Ensure videoId is correct and asset exists.")));
    }

    return Scaffold(
      backgroundColor: Colors.black, // Ensure player background is black
      body: GestureDetector(
        onTap: () {
          if (mounted) setState(() => controlsVisible = !controlsVisible);
          if (controlsVisible) _autoHide(); // Re-start auto hide if controls are shown again
        },
        onDoubleTap: () {
          if (!ctrl.value.isInitialized) return;
          if (mounted) setState(() => ctrl.value.isPlaying ? ctrl.pause() : ctrl.play());
        },
        onHorizontalDragEnd: (_) { // Document says onHorizontalDragEnd: (_) => Navigator.pop(context)
            if (Navigator.canPop(context)) Navigator.pop(context);
        },
        child: Stack(
          alignment: Alignment.center, // Center children in the stack
          children: [
            AspectRatio(
              aspectRatio: ctrl.value.aspectRatio,
              child: VideoPlayer(ctrl),
            ),
            if (controlsVisible)
              Icon(
                ctrl.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: Colors.white70,
                size: 96,
              ),
            if (QuizManager.shouldShow()) const InteractiveQuizOverlay(), // Position this as needed
            Positioned(
              top: 40,
              right: 24,
              child: RewardIndicator(progress: RewardBloc.state),
            )
          ],
        ),
      ),
    );
  }
}
