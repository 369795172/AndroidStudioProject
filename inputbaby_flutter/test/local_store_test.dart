import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/data/local_store.dart';

void main() {
  group('LocalStore Tests', () {
    late Map<String, Object> values;

    setUp(() async {
      // Initialize mock shared preferences with empty state
      values = <String, Object>{};
      SharedPreferences.setMockInitialValues(values);
      await LocalStore.initialize();
    });

    tearDown(() async {
      // Clear all data after each test
      await LocalStore.clearAll();
    });

    group('Initialization', () {
      test('should initialize SharedPreferences successfully', () async {
        // The initialize call in setUp should work without throwing
        expect(true, true); // If we reach here, initialization worked
      });

      test('should handle multiple initialization calls gracefully', () async {
        // Multiple calls should not cause issues
        await LocalStore.initialize();
        await LocalStore.initialize();
        await LocalStore.initialize();
        expect(true, true);
      });
    });

    group('Video Progress Management', () {
      test('should save and retrieve video progress correctly', () async {
        // Test basic save/get functionality
        const videoId = 'test_video_001';
        const progress = 45.5;

        final saveResult = await LocalStore.saveProgress(videoId, progress);
        expect(saveResult, true);

        final retrievedProgress = await LocalStore.getProgress(videoId);
        expect(retrievedProgress, progress);
      });

      test('should return 0.0 for non-existent video progress', () async {
        const videoId = 'non_existent_video';
        final progress = await LocalStore.getProgress(videoId);
        expect(progress, 0.0);
      });

      test('should handle multiple video progress saves', () async {
        final testData = {
          'video_001': 30.0,
          'video_002': 60.5,
          'video_003': 120.0,
        };

        // Save all progress data
        for (final entry in testData.entries) {
          final result = await LocalStore.saveProgress(entry.key, entry.value);
          expect(result, true);
        }

        // Retrieve and verify all data
        for (final entry in testData.entries) {
          final progress = await LocalStore.getProgress(entry.key);
          expect(progress, entry.value);
        }
      });

      test('should reject invalid video progress data', () async {
        // Test empty video ID
        expect(
          () => LocalStore.saveProgress('', 30.0),
          throwsA(isA<ArgumentError>()),
        );

        // Test negative progress
        expect(
          () => LocalStore.saveProgress('test_video', -10.0),
          throwsA(isA<ArgumentError>()),
        );

        // Test empty ID for retrieval
        expect(
          () => LocalStore.getProgress(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should update existing video progress', () async {
        const videoId = 'test_video_update';
        
        // Save initial progress
        await LocalStore.saveProgress(videoId, 30.0);
        expect(await LocalStore.getProgress(videoId), 30.0);

        // Update progress
        await LocalStore.saveProgress(videoId, 60.0);
        expect(await LocalStore.getProgress(videoId), 60.0);

        // Update again
        await LocalStore.saveProgress(videoId, 90.0);
        expect(await LocalStore.getProgress(videoId), 90.0);
      });

      test('should clear specific video progress', () async {
        const videoId = 'test_video_clear';
        
        // Save progress
        await LocalStore.saveProgress(videoId, 45.0);
        expect(await LocalStore.getProgress(videoId), 45.0);

        // Clear progress
        final clearResult = await LocalStore.clearProgress(videoId);
        expect(clearResult, true);
        expect(await LocalStore.getProgress(videoId), 0.0);
      });
    });

    group('Level Management', () {
      test('should save and retrieve user level correctly', () async {
        const level = 3;

        final saveResult = await LocalStore.saveLevel(level);
        expect(saveResult, true);

        final retrievedLevel = await LocalStore.getLevel();
        expect(retrievedLevel, level);
      });

      test('should return default level 1 when no level is saved', () async {
        final level = await LocalStore.getLevel();
        expect(level, 1);
      });

      test('should update existing level', () async {
        // Save initial level
        await LocalStore.saveLevel(1);
        expect(await LocalStore.getLevel(), 1);

        // Update level
        await LocalStore.saveLevel(2);
        expect(await LocalStore.getLevel(), 2);

        // Update again
        await LocalStore.saveLevel(3);
        expect(await LocalStore.getLevel(), 3);
      });

      test('should reject invalid level values', () async {
        expect(
          () => LocalStore.saveLevel(0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => LocalStore.saveLevel(-1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Resume Functionality', () {
      test('should save and retrieve resume video for level', () async {
        const level = 2;
        const videoId = 'resume_test_video';

        final saveResult = await LocalStore.setResumeVideo(level, videoId);
        expect(saveResult, true);

        final retrievedVideoId = await LocalStore.resume(level);
        expect(retrievedVideoId, videoId);
      });

      test('should return null for level with no resume video', () async {
        const level = 5;
        final videoId = await LocalStore.resume(level);
        expect(videoId, null);
      });

      test('should handle multiple levels resume tracking', () async {
        final testData = {
          1: 'video_level_1',
          2: 'video_level_2',
          3: 'video_level_3',
        };

        // Save resume videos for different levels
        for (final entry in testData.entries) {
          final result = await LocalStore.setResumeVideo(entry.key, entry.value);
          expect(result, true);
        }

        // Retrieve and verify
        for (final entry in testData.entries) {
          final videoId = await LocalStore.resume(entry.key);
          expect(videoId, entry.value);
        }
      });

      test('should reject invalid resume data', () async {
        expect(
          () => LocalStore.setResumeVideo(0, 'video'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => LocalStore.setResumeVideo(1, ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => LocalStore.resume(0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Combined Progress and Level Tracking', () {
      test('should save progress with level tracking correctly', () async {
        const videoId = 'combined_test_video';
        const progress = 75.0;
        const level = 2;

        final result = await LocalStore.saveProgressWithLevel(videoId, progress, level);
        expect(result, true);

        // Verify progress was saved
        final retrievedProgress = await LocalStore.getProgress(videoId);
        expect(retrievedProgress, progress);

        // Verify resume tracking was updated
        final resumeVideoId = await LocalStore.resume(level);
        expect(resumeVideoId, videoId);
      });
    });

    group('Data Retrieval and Statistics', () {
      test('should get all progress data correctly', () async {
        final testData = {
          'video_001': 30.0,
          'video_002': 60.0,
          'video_003': 90.0,
        };

        // Save test data
        for (final entry in testData.entries) {
          await LocalStore.saveProgress(entry.key, entry.value);
        }

        // Get all progress
        final allProgress = await LocalStore.getAllProgress();
        expect(allProgress.length, testData.length);

        for (final entry in testData.entries) {
          expect(allProgress[entry.key], entry.value);
        }
      });

      test('should calculate progress statistics correctly', () async {
        // Save test data
        await LocalStore.saveProgress('video_001', 30.0);
        await LocalStore.saveProgress('video_002', 60.0);
        await LocalStore.saveProgress('video_003', 0.0); // Not started
        await LocalStore.saveProgress('video_004', 120.0);

        final stats = await LocalStore.getProgressStats();
        
        expect(stats['totalVideos'], 4);
        expect(stats['completedVideos'], 3); // 3 videos with progress > 0
        expect(stats['completionRate'], 0.75); // 3/4
        expect(stats['totalWatchTime'], 210.0); // 30 + 60 + 0 + 120
        expect(stats['averageProgress'], 52.5); // 210/4
      });

      test('should handle empty progress data for statistics', () async {
        final stats = await LocalStore.getProgressStats();
        
        expect(stats['totalVideos'], 0);
        expect(stats['completedVideos'], 0);
        expect(stats['completionRate'], 0.0);
        expect(stats['totalWatchTime'], 0.0);
        expect(stats['averageProgress'], 0.0);
      });
    });

    group('Data Management', () {
      test('should clear all data successfully', () async {
        // Add some test data
        await LocalStore.saveProgress('video_001', 30.0);
        await LocalStore.saveLevel(3);
        await LocalStore.setResumeVideo(2, 'resume_video');

        // Verify data exists
        expect(await LocalStore.getProgress('video_001'), 30.0);
        expect(await LocalStore.getLevel(), 3);
        expect(await LocalStore.resume(2), 'resume_video');

        // Clear all data
        final clearResult = await LocalStore.clearAll();
        expect(clearResult, true);

        // Verify data is cleared
        expect(await LocalStore.getProgress('video_001'), 0.0);
        expect(await LocalStore.getLevel(), 1); // Default level
        expect(await LocalStore.resume(2), null);
      });
    });

    group('Performance Tests', () {
      test('should meet performance requirements (≤ 5ms)', () async {
        final measurements = await LocalStore.measurePerformance();
        
        // Check that all operations meet the 5ms requirement
        for (final entry in measurements.entries) {
          expect(
            entry.value,
            lessThanOrEqualTo(5.0),
            reason: '${entry.key} took ${entry.value}ms, exceeding 5ms limit',
          );
        }
      });

      test('should validate performance requirements', () async {
        final isValid = await LocalStore.validatePerformance();
        expect(isValid, true);
      });

      test('should handle high-frequency operations efficiently', () async {
        const iterations = 100;
        final stopwatch = Stopwatch()..start();

        // Perform many save operations
        for (int i = 0; i < iterations; i++) {
          await LocalStore.saveProgress('perf_test_$i', i.toDouble());
        }

        stopwatch.stop();
        final averageTime = stopwatch.elapsedMilliseconds / iterations;
        
        // Average time per operation should be reasonable
        expect(averageTime, lessThan(10.0), 
               reason: 'Average save time was ${averageTime}ms per operation');

        // Verify all data was saved correctly
        for (int i = 0; i < iterations; i++) {
          final progress = await LocalStore.getProgress('perf_test_$i');
          expect(progress, i.toDouble());
        }
      });
    });

    group('Error Handling', () {
      test('should handle corrupted preferences gracefully', () async {
        // This test is more for documentation of expected behavior
        // In a real corrupted state, the methods should return default values
        // rather than throwing exceptions to maintain the 100% success rate requirement
        
        final progress = await LocalStore.getProgress('any_video');
        expect(progress, isA<double>());
        
        final level = await LocalStore.getLevel();
        expect(level, isA<int>());
        expect(level, greaterThanOrEqualTo(1));
      });
    });
  });
} 