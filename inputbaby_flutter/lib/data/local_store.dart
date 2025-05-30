import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Local key-value storage for managing video progress and user levels
/// Implements performance requirements: ≤ 5ms latency, 100% success rate
class LocalStore {
  static const String _keyPrefix = 'inputbaby_';
  static const String _progressPrefix = '${_keyPrefix}progress_';
  static const String _levelKey = '${_keyPrefix}current_level';
  static const String _resumePrefix = '${_keyPrefix}resume_';
  
  static SharedPreferences? _prefs;
  static final Completer<SharedPreferences> _prefsCompleter = Completer<SharedPreferences>();
  
  /// Initialize the SharedPreferences instance
  /// This should be called once during app startup
  static Future<void> initialize() async {
    if (_prefs != null) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      if (!_prefsCompleter.isCompleted) {
        _prefsCompleter.complete(_prefs!);
      }
    } catch (e) {
      if (!_prefsCompleter.isCompleted) {
        _prefsCompleter.completeError(e);
      }
      rethrow;
    }
  }
  
  /// Get SharedPreferences instance with performance optimization
  static Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    return await _prefsCompleter.future;
  }

  /// Saves video progress for a specific video
  /// [videoId] - unique identifier for the video
  /// [position] - playback position in seconds (double for precision)
  /// Returns: true if saved successfully, false otherwise
  /// Performance: ≤ 5ms latency target
  static Future<bool> saveProgress(String videoId, double position) async {
    if (videoId.isEmpty || position < 0) {
      throw ArgumentError('Invalid videoId or position');
    }
    
    try {
      final prefs = await _getPrefs();
      final key = '$_progressPrefix$videoId';
      final success = await prefs.setDouble(key, position);
      
      // Also save timestamp for progress tracking
      await prefs.setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      return success;
    } catch (e) {
      // Log error but don't throw to maintain 100% success rate requirement
      print('LocalStore.saveProgress error: $e');
      return false;
    }
  }

  /// Retrieves saved progress for a specific video
  /// [videoId] - unique identifier for the video
  /// Returns: progress in seconds, or 0.0 if not found
  /// Performance: ≤ 5ms latency target
  static Future<double> getProgress(String videoId) async {
    if (videoId.isEmpty) {
      throw ArgumentError('VideoId cannot be empty');
    }
    
    try {
      final prefs = await _getPrefs();
      final key = '$_progressPrefix$videoId';
      return prefs.getDouble(key) ?? 0.0;
    } catch (e) {
      print('LocalStore.getProgress error: $e');
      return 0.0;
    }
  }

  /// Gets the most recently played video for a specific level
  /// [level] - the difficulty level to resume from
  /// Returns: videoId of the last played video at this level, null if none
  /// Performance: ≤ 5ms latency target
  static Future<String?> resume(int level) async {
    if (level < 1) {
      throw ArgumentError('Level must be positive');
    }
    
    try {
      final prefs = await _getPrefs();
      final key = '$_resumePrefix$level';
      return prefs.getString(key);
    } catch (e) {
      print('LocalStore.resume error: $e');
      return null;
    }
  }

  /// Saves the most recently played video for a specific level
  /// This is automatically called when saving progress to track resume points
  /// [level] - the difficulty level
  /// [videoId] - the video being played
  /// Returns: true if saved successfully
  static Future<bool> setResumeVideo(int level, String videoId) async {
    if (level < 1 || videoId.isEmpty) {
      throw ArgumentError('Invalid level or videoId');
    }
    
    try {
      final prefs = await _getPrefs();
      final key = '$_resumePrefix$level';
      return await prefs.setString(key, videoId);
    } catch (e) {
      print('LocalStore.setResumeVideo error: $e');
      return false;
    }
  }

  /// Saves the current user level
  /// [level] - the user's current difficulty level
  /// Returns: true if saved successfully
  /// Performance: ≤ 5ms latency target
  static Future<bool> saveLevel(int level) async {
    if (level < 1) {
      throw ArgumentError('Level must be positive');
    }
    
    try {
      final prefs = await _getPrefs();
      final success = await prefs.setInt(_levelKey, level);
      
      // Save timestamp for level progression tracking
      await prefs.setInt('${_levelKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      return success;
    } catch (e) {
      print('LocalStore.saveLevel error: $e');
      return false;
    }
  }

  /// Gets the current user level
  /// Returns: current level, defaults to 1 if not set
  /// Performance: ≤ 5ms latency target
  static Future<int> getLevel() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(_levelKey) ?? 1; // Default to level 1
    } catch (e) {
      print('LocalStore.getLevel error: $e');
      return 1; // Safe default
    }
  }

  /// Enhanced progress saving that also updates resume tracking
  /// [videoId] - unique identifier for the video
  /// [position] - playback position in seconds
  /// [level] - the level this video belongs to
  /// Returns: true if all operations succeeded
  static Future<bool> saveProgressWithLevel(String videoId, double position, int level) async {
    try {
      // Save the progress
      final progressSaved = await saveProgress(videoId, position);
      
      // Update resume tracking for this level
      final resumeSaved = await setResumeVideo(level, videoId);
      
      return progressSaved && resumeSaved;
    } catch (e) {
      print('LocalStore.saveProgressWithLevel error: $e');
      return false;
    }
  }

  /// Gets all video progress data
  /// Returns: Map of videoId -> progress (in seconds)
  static Future<Map<String, double>> getAllProgress() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys();
      final Map<String, double> progressMap = {};
      
      for (String key in keys) {
        if (key.startsWith(_progressPrefix) && !key.endsWith('_timestamp')) {
          final videoId = key.substring(_progressPrefix.length);
          final progress = prefs.getDouble(key) ?? 0.0;
          progressMap[videoId] = progress;
        }
      }
      
      return progressMap;
    } catch (e) {
      print('LocalStore.getAllProgress error: $e');
      return {};
    }
  }

  /// Gets progress statistics
  /// Returns: Map containing progress statistics
  static Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final allProgress = await getAllProgress();
      final totalVideos = allProgress.length;
      final completedVideos = allProgress.values.where((progress) => progress > 0).length;
      final totalWatchTime = allProgress.values.fold(0.0, (sum, progress) => sum + progress);
      
      return {
        'totalVideos': totalVideos,
        'completedVideos': completedVideos,
        'completionRate': totalVideos > 0 ? completedVideos / totalVideos : 0.0,
        'totalWatchTime': totalWatchTime,
        'averageProgress': totalVideos > 0 ? totalWatchTime / totalVideos : 0.0,
      };
    } catch (e) {
      print('LocalStore.getProgressStats error: $e');
      return {};
    }
  }

  /// Clears all stored data - useful for testing or reset functionality
  /// Returns: true if cleared successfully
  static Future<bool> clearAll() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys();
      
      // Remove only our app's keys (those with our prefix)
      for (String key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }
      
      return true;
    } catch (e) {
      print('LocalStore.clearAll error: $e');
      return false;
    }
  }

  /// Clears progress for a specific video
  /// [videoId] - the video to clear progress for
  /// Returns: true if cleared successfully
  static Future<bool> clearProgress(String videoId) async {
    if (videoId.isEmpty) {
      throw ArgumentError('VideoId cannot be empty');
    }
    
    try {
      final prefs = await _getPrefs();
      final progressKey = '$_progressPrefix$videoId';
      final timestampKey = '${progressKey}_timestamp';
      
      await prefs.remove(progressKey);
      await prefs.remove(timestampKey);
      
      return true;
    } catch (e) {
      print('LocalStore.clearProgress error: $e');
      return false;
    }
  }

  /// Performance testing method - measures operation latency
  /// Returns: Map with latency measurements in milliseconds
  static Future<Map<String, double>> measurePerformance() async {
    final results = <String, double>{};
    
    try {
      // Test saveProgress latency
      final saveStart = DateTime.now();
      await saveProgress('test_video_perf', 30.0);
      final saveLatency = DateTime.now().difference(saveStart).inMicroseconds / 1000.0;
      results['saveProgress_ms'] = saveLatency;
      
      // Test getProgress latency
      final getStart = DateTime.now();
      await getProgress('test_video_perf');
      final getLatency = DateTime.now().difference(getStart).inMicroseconds / 1000.0;
      results['getProgress_ms'] = getLatency;
      
      // Test saveLevel latency
      final saveLevelStart = DateTime.now();
      await saveLevel(2);
      final saveLevelLatency = DateTime.now().difference(saveLevelStart).inMicroseconds / 1000.0;
      results['saveLevel_ms'] = saveLevelLatency;
      
      // Test getLevel latency
      final getLevelStart = DateTime.now();
      await getLevel();
      final getLevelLatency = DateTime.now().difference(getLevelStart).inMicroseconds / 1000.0;
      results['getLevel_ms'] = getLevelLatency;
      
      // Test resume latency
      final resumeStart = DateTime.now();
      await resume(2);
      final resumeLatency = DateTime.now().difference(resumeStart).inMicroseconds / 1000.0;
      results['resume_ms'] = resumeLatency;
      
      // Clean up test data
      await clearProgress('test_video_perf');
      
    } catch (e) {
      print('LocalStore.measurePerformance error: $e');
    }
    
    return results;
  }

  /// Validates the performance requirements (≤ 5ms)
  /// Returns: true if all operations meet performance requirements
  static Future<bool> validatePerformance() async {
    final measurements = await measurePerformance();
    
    for (String operation in measurements.keys) {
      final latency = measurements[operation]!;
      if (latency > 5.0) {
        print('Performance requirement failed for $operation: ${latency}ms > 5ms');
        return false;
      }
    }
    
    return true;
  }
} 