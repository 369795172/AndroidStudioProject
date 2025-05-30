import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome and SystemNavigator
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
  print("[findAsset] Looking for videoId: $videoId");
  // 为了测试，所有videoId都映射到sample.mp4
  // 注意：在Flutter assets中，路径应该是相对于pubspec.yaml的
  const assetPath = "assets/videos/sample.mp4";
  print("[findAsset] Returning asset path: $assetPath");
  return assetPath;
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
        // Remove static routes to force onGenerateRoute handling
        // routes: {
        //   '/': (_) => const VideoHomePage(),
        //   '/player': (c) {
        //     print("[InputBabyApp] Navigating to /player route");
        //     return const VideoPlayerPage();
        //   },
        // },
        // The initial route is typically set by the native side via FlutterEngine.navigationChannel.setInitialRoute()
        initialRoute: '/',
        onGenerateRoute: (settings) {
          print("[InputBabyApp] ===================");
          print("[InputBabyApp] onGenerateRoute called with: ${settings.name}");
          print("[InputBabyApp] Settings arguments: ${settings.arguments}");
          
          // Handle /player route with query parameters FIRST (highest priority)
          if (settings.name != null && settings.name!.startsWith('/player')) {
            print("[InputBabyApp] ✅ Detected /player route: ${settings.name}");
            print("[InputBabyApp] Creating VideoPlayerPage directly...");
            return MaterialPageRoute(
              builder: (context) {
                print("[InputBabyApp] Building VideoPlayerPage with route: ${settings.name}");
                return const VideoPlayerPage();
              },
              settings: settings,
            );
          }
          
          // Handle home route
          if (settings.name == '/' || settings.name == null) {
            print("[InputBabyApp] Detected home route, creating VideoHomePage");
            return MaterialPageRoute(
              builder: (context) => const VideoHomePage(),
              settings: settings,
            );
          }
          
          // Fallback to home page
          print("[InputBabyApp] ⚠️ Unknown route: ${settings.name}, falling back to home");
          return MaterialPageRoute(
            builder: (context) => const VideoHomePage(),
            settings: settings,
          );
        },
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
    print("[VideoPlayerPage] ===================");
    print("[VideoPlayerPage] _initializePlayer called");
    print("[VideoPlayerPage] Route name: $routeName");
    print("[VideoPlayerPage] Context mounted: $mounted");
    
    if (routeName == null) {
      print("[VideoPlayerPage] ERROR: Route name is null. Cannot initialize player.");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
      return;
    }

    try {
      // Parse the route - could be "/player" or "/player?level=1&videoId=someId"
      final Uri args = Uri.parse(routeName);
      final videoId = args.queryParameters['videoId'] ?? 'video2'; // 默认使用继续观看的video2
      final level = args.queryParameters['level'] ?? '1'; // Default fallback

      print("[VideoPlayerPage] Parsed route successfully: $routeName");
      print("[VideoPlayerPage] VideoId: $videoId, Level: $level");

      // Get the asset path for the video
      final assetPath = findAsset(videoId);
      print("[VideoPlayerPage] Asset path: $assetPath");
      print("[VideoPlayerPage] About to create VideoPlayerController...");

      // Try to initialize video controller with local asset first
      // If that fails, we can fallback to a test network video
      ctrl = VideoPlayerController.asset(assetPath)
        ..initialize().then((_) {
          if (!mounted) {
            print("[VideoPlayerPage] Widget unmounted during initialization");
            return;
          }
          print("[VideoPlayerPage] ✅ Video controller initialized successfully");
          print("[VideoPlayerPage] Video duration: ${ctrl.value.duration}");
          print("[VideoPlayerPage] Video size: ${ctrl.value.size}");
          print("[VideoPlayerPage] Video aspect ratio: ${ctrl.value.aspectRatio}");
          
          setState(() {
            _isLoading = false;
            _isError = false;
          });
          
          // Start playing
          ctrl.play();
          print("[VideoPlayerPage] Video playback started");
          
          // Add listener and auto hide
          ctrl.addListener(_tick);
          _autoHide();
        }).catchError((error) {
          print("[VideoPlayerPage] ❌ Error initializing local asset video: $error");
          print("[VideoPlayerPage] Error type: ${error.runtimeType}");
          print("[VideoPlayerPage] Trying fallback to test network video...");
          
          // Fallback to a test network video to verify the player works
          _tryNetworkVideo();
        });
    } catch (e) {
      print("[VideoPlayerPage] ❌ Exception in _initializePlayer: $e");
      print("[VideoPlayerPage] Exception type: ${e.runtimeType}");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    }
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

  void _tryNetworkVideo() {
    print("[VideoPlayerPage] Trying fallback to network video...");
    
    if (!mounted) return;
    
    // Try a small test video from the web
    const testVideoUrl = "https://sample-videos.com/zip/10/mp4/SampleVideo_360x240_1mb.mp4";
    print("[VideoPlayerPage] Attempting to load test video: $testVideoUrl");
    
    try {
      // Dispose the previous controller if it exists
      if (ctrl.value.isInitialized) {
        ctrl.dispose();
      }
      
      ctrl = VideoPlayerController.network(testVideoUrl)
        ..initialize().then((_) {
          if (!mounted) {
            print("[VideoPlayerPage] Widget unmounted during network video initialization");
            return;
          }
          print("[VideoPlayerPage] ✅ Network video controller initialized successfully");
          print("[VideoPlayerPage] Network video duration: ${ctrl.value.duration}");
          print("[VideoPlayerPage] Network video size: ${ctrl.value.size}");
          print("[VideoPlayerPage] Network video aspect ratio: ${ctrl.value.aspectRatio}");
          
          setState(() {
            _isLoading = false;
            _isError = false;
          });
          
          // Start playing
          ctrl.play();
          print("[VideoPlayerPage] Network video playback started");
          
          // Add listener and auto hide
          ctrl.addListener(_tick);
          _autoHide();
        }).catchError((networkError) {
          print("[VideoPlayerPage] ❌ Error initializing network video: $networkError");
          print("[VideoPlayerPage] Network error type: ${networkError.runtimeType}");
          
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isError = true;
            });
          }
        });
    } catch (e) {
      print("[VideoPlayerPage] ❌ Exception trying network video: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    ctrl.removeListener(_tick);
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("[VideoPlayerPage] build() called - isLoading: $_isLoading, isError: $_isError");
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                "正在加载视频...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_isError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "视频加载失败",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "请检查视频文件是否存在",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  print("[VideoPlayerPage] Return button pressed - finishing activity");
                  // Use SystemNavigator to close the entire Flutter activity
                  SystemNavigator.pop();
                },
                child: const Text("返回"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print("[VideoPlayerPage] Retry button pressed");
                  setState(() {
                    _isLoading = true;
                    _isError = false;
                  });
                  _initializePlayer();
                },
                child: const Text("重试"),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!ctrl.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                "视频控制器未初始化",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    print("[VideoPlayerPage] Rendering video player UI");
    return Scaffold(
      backgroundColor: Colors.black, // Ensure player background is black
      body: GestureDetector(
        onTap: () {
          print("[VideoPlayerPage] Screen tapped - controlsVisible: $controlsVisible");
          if (mounted) setState(() => controlsVisible = !controlsVisible);
          if (controlsVisible) _autoHide(); // Re-start auto hide if controls are shown again
        },
        onDoubleTap: () {
          if (!ctrl.value.isInitialized) return;
          final isPlaying = ctrl.value.isPlaying;
          print("[VideoPlayerPage] Double tapped - isPlaying: $isPlaying");
          if (mounted) setState(() => isPlaying ? ctrl.pause() : ctrl.play());
        },
        onHorizontalDragEnd: (_) { // Document says onHorizontalDragEnd: (_) => Navigator.pop(context)
          print("[VideoPlayerPage] Horizontal drag detected - finishing activity");
          SystemNavigator.pop(); // Use SystemNavigator instead of Navigator.pop
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
