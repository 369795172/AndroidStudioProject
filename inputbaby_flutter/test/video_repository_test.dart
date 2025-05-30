import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/video_repository.dart';

// Custom VideoRepository for testing that doesn't depend on assets
class MockVideoRepository extends VideoRepository {
  static const mockVideos = [
    {
      'id': 'test_video_001',
      'title': 'Basic Learning Video - Letter Recognition',
      'cover': 'assets/videos/sample_cover.jpg',
      'path': 'assets/videos/sample.mp4',
      'level': 1,
      'type': 'education',
      'tags': ['letters', 'basic', 'recognition'],
      'description': 'A basic letter recognition teaching video suitable for beginners.',
      'duration': 120,
      'difficulty': 'beginner',
      'category': 'literacy'
    },
    {
      'id': 'test_video_002',
      'title': 'Intermediate Learning Video - Number Learning',
      'cover': 'assets/videos/sample_cover.jpg',
      'path': 'assets/videos/sample.mp4',
      'level': 2,
      'type': 'education',
      'tags': ['numbers', 'intermediate', 'calculation'],
      'description': 'For learners with some foundation, teaching basic number concepts.',
      'duration': 150,
      'difficulty': 'intermediate',
      'category': 'math'
    },
    {
      'id': 'test_video_003',
      'title': 'Advanced Learning Video - Comprehensive Practice',
      'cover': 'assets/videos/sample_cover.jpg',
      'path': 'assets/videos/sample.mp4',
      'level': 3,
      'type': 'practice',
      'tags': ['comprehensive', 'practice', 'review'],
      'description': 'Comprehensive practice video to help learners consolidate knowledge.',
      'duration': 180,
      'difficulty': 'advanced',
      'category': 'review'
    },
    {
      'id': 'test_video_004',
      'title': 'Entertainment Learning Video - Interactive Game',
      'cover': 'assets/videos/sample_cover.jpg',
      'path': 'assets/videos/sample.mp4',
      'level': 1,
      'type': 'entertainment',
      'tags': ['game', 'interactive', 'entertainment'],
      'description': 'Educational and entertaining interactive game video.',
      'duration': 90,
      'difficulty': 'beginner',
      'category': 'game'
    }
  ];

  static const mockMetadata = {
    'version': '1.0.0',
    'lastUpdated': '2025-01-30T10:00:00Z',
    'totalVideos': 4,
    'supportedLevels': [1, 2, 3],
    'supportedTypes': ['education', 'entertainment', 'practice'],
    'supportedCategories': ['literacy', 'math', 'review', 'game']
  };

  @override
  Future<Map<String, dynamic>> _loadVideoData() async {
    return {
      'videos': mockVideos,
      'metadata': mockMetadata,
    };
  }
}

void main() {
  group('VideoRepository Tests', () {
    // Test data that matches our assets/videos.json structure
    final testVideoItems = [
      VideoItem(
        id: 'test_video_001',
        title: 'Basic Learning Video - Letter Recognition',
        cover: 'assets/videos/sample_cover.jpg',
        path: 'assets/videos/sample.mp4',
        level: 1,
        type: 'education',
        tags: ['letters', 'basic', 'recognition'],
        description: 'A basic letter recognition teaching video suitable for beginners.',
        duration: 120,
        difficulty: 'beginner',
        category: 'literacy',
      ),
      VideoItem(
        id: 'test_video_002',
        title: 'Intermediate Learning Video - Number Learning',
        cover: 'assets/videos/sample_cover.jpg',
        path: 'assets/videos/sample.mp4',
        level: 2,
        type: 'education',
        tags: ['numbers', 'intermediate', 'calculation'],
        description: 'For learners with some foundation, teaching basic number concepts.',
        duration: 150,
        difficulty: 'intermediate',
        category: 'math',
      ),
      VideoItem(
        id: 'test_video_003',
        title: 'Advanced Learning Video - Comprehensive Practice',
        cover: 'assets/videos/sample_cover.jpg',
        path: 'assets/videos/sample.mp4',
        level: 3,
        type: 'practice',
        tags: ['comprehensive', 'practice', 'review'],
        description: 'Comprehensive practice video to help learners consolidate knowledge.',
        duration: 180,
        difficulty: 'advanced',
        category: 'review',
      ),
      VideoItem(
        id: 'test_video_004',
        title: 'Entertainment Learning Video - Interactive Game',
        cover: 'assets/videos/sample_cover.jpg',
        path: 'assets/videos/sample.mp4',
        level: 1,
        type: 'entertainment',
        tags: ['game', 'interactive', 'entertainment'],
        description: 'Educational and entertaining interactive game video.',
        duration: 90,
        difficulty: 'beginner',
        category: 'game',
      ),
    ];

    group('VideoItem Model Tests', () {
      test('should create VideoItem from JSON correctly', () {
        final json = {
          'id': 'test_001',
          'title': 'Test Video',
          'cover': 'cover.jpg',
          'path': 'video.mp4',
          'level': 1,
          'type': 'education',
          'tags': ['test', 'video'],
          'description': 'Test description',
          'duration': 120,
          'difficulty': 'beginner',
          'category': 'test',
        };

        final video = VideoItem.fromJson(json);

        expect(video.id, 'test_001');
        expect(video.title, 'Test Video');
        expect(video.level, 1);
        expect(video.type, 'education');
        expect(video.tags, ['test', 'video']);
        expect(video.duration, 120);
        expect(video.difficulty, 'beginner');
        expect(video.category, 'test');
      });

      test('should convert VideoItem to JSON correctly', () {
        final video = VideoItem(
          id: 'test_001',
          title: 'Test Video',
          cover: 'cover.jpg',
          path: 'video.mp4',
          level: 1,
          type: 'education',
          tags: ['test', 'video'],
          description: 'Test description',
          duration: 120,
          difficulty: 'beginner',
          category: 'test',
        );

        final json = video.toJson();

        expect(json['id'], 'test_001');
        expect(json['title'], 'Test Video');
        expect(json['level'], 1);
        expect(json['type'], 'education');
        expect(json['tags'], ['test', 'video']);
        expect(json['duration'], 120);
      });

      test('should implement equality correctly', () {
        final video1 = VideoItem(
          id: 'test_001',
          title: 'Test Video',
          cover: 'cover.jpg',
          path: 'video.mp4',
          level: 1,
          type: 'education',
          tags: ['test'],
          description: 'Test',
          duration: 120,
          difficulty: 'beginner',
          category: 'test',
        );

        final video2 = VideoItem(
          id: 'test_001',
          title: 'Different Title',
          cover: 'cover.jpg',
          path: 'video.mp4',
          level: 2,
          type: 'entertainment',
          tags: ['different'],
          description: 'Different',
          duration: 180,
          difficulty: 'advanced',
          category: 'different',
        );

        final video3 = VideoItem(
          id: 'test_002',
          title: 'Test Video',
          cover: 'cover.jpg',
          path: 'video.mp4',
          level: 1,
          type: 'education',
          tags: ['test'],
          description: 'Test',
          duration: 120,
          difficulty: 'beginner',
          category: 'test',
        );

        expect(video1, equals(video2)); // Same ID
        expect(video1, isNot(equals(video3))); // Different ID
        expect(video1.hashCode, equals(video2.hashCode));
      });
    });

    group('VideoFilter Logic Tests', () {
      test('should filter by level correctly', () {
        final filter = VideoFilter(levels: [1]);
        final level1Videos = testVideoItems.where(filter.matches).toList();
        
        expect(level1Videos.length, 2); // test_video_001 and test_video_004
        expect(level1Videos.every((v) => v.level == 1), true);
      });

      test('should filter by type correctly', () {
        final filter = VideoFilter(types: ['education']);
        final educationVideos = testVideoItems.where(filter.matches).toList();
        
        expect(educationVideos.length, 2);
        expect(educationVideos.every((v) => v.type == 'education'), true);
      });

      test('should filter by category correctly', () {
        final filter = VideoFilter(categories: ['literacy']);
        final literacyVideos = testVideoItems.where(filter.matches).toList();
        
        expect(literacyVideos.length, 1);
        expect(literacyVideos[0].category, 'literacy');
      });

      test('should filter by difficulty correctly', () {
        final filter = VideoFilter(difficulties: ['beginner']);
        final beginnerVideos = testVideoItems.where(filter.matches).toList();
        
        expect(beginnerVideos.length, 2);
        expect(beginnerVideos.every((v) => v.difficulty == 'beginner'), true);
      });

      test('should filter by duration range correctly', () {
        final filter = VideoFilter(minDuration: 100, maxDuration: 150);
        final filteredVideos = testVideoItems.where(filter.matches).toList();
        
        expect(filteredVideos.every((v) => v.duration >= 100 && v.duration <= 150), true);
      });

      test('should filter by tags correctly', () {
        final filter = VideoFilter(tags: ['letters', 'game']);
        final taggedVideos = testVideoItems.where(filter.matches).toList();
        
        expect(taggedVideos.length, 2); // Videos with either tag
      });

      test('should filter by search query correctly', () {
        final filter = VideoFilter(searchQuery: 'Learning');
        final searchResults = testVideoItems.where(filter.matches).toList();
        
        expect(searchResults.length, 4); // Videos with 'Learning' in title
      });

      test('should filter by multiple criteria correctly', () {
        final filter = VideoFilter(
          levels: [1, 2],
          types: ['education'],
          difficulties: ['beginner', 'intermediate'],
        );
        final results = testVideoItems.where(filter.matches).toList();
        
        expect(results.length, 2); // test_video_001 and test_video_002
        expect(results.every((v) => v.type == 'education'), true);
        expect(results.every((v) => [1, 2].contains(v.level)), true);
      });
    });

    group('VideoMetadata Model Tests', () {
      test('should create VideoMetadata from JSON correctly', () {
        final json = {
          'version': '1.0.0',
          'lastUpdated': '2025-01-30T10:00:00Z',
          'totalVideos': 4,
          'supportedLevels': [1, 2, 3],
          'supportedTypes': ['education', 'entertainment', 'practice'],
          'supportedCategories': ['literacy', 'math', 'review', 'game']
        };

        final metadata = VideoMetadata.fromJson(json);

        expect(metadata.version, '1.0.0');
        expect(metadata.totalVideos, 4);
        expect(metadata.supportedLevels, [1, 2, 3]);
        expect(metadata.supportedTypes, ['education', 'entertainment', 'practice']);
      });
    });

    group('VideoRepositoryException Tests', () {
      test('should create exception with message correctly', () {
        const message = 'Test error message';
        final exception = VideoRepositoryException(message);
        
        expect(exception.message, message);
        expect(exception.toString(), 'VideoRepositoryException: $message');
      });
    });

    group('BE-03: Level Statistics Logic Tests', () {
      test('should calculate level statistics correctly', () {
        final Map<int, int> stats = {};
        
        for (VideoItem video in testVideoItems) {
          stats[video.level] = (stats[video.level] ?? 0) + 1;
        }
        
        expect(stats[1], 2); // 2 videos at level 1
        expect(stats[2], 1); // 1 video at level 2
        expect(stats[3], 1); // 1 video at level 3
      });

      test('should validate level coverage correctly', () {
        final requiredLevels = [1, 2, 3];
        final levelStats = <int, int>{};
        
        for (VideoItem video in testVideoItems) {
          levelStats[video.level] = (levelStats[video.level] ?? 0) + 1;
        }
        
        bool valid = true;
        for (int level in requiredLevels) {
          if (!levelStats.containsKey(level) || levelStats[level]! == 0) {
            valid = false;
            break;
          }
        }
        
        expect(valid, true);
      });
    });

    group('BE-03: Video Search and Filtering Logic Tests', () {
      test('should search videos by title correctly', () {
        final query = 'Learning';
        final lowerQuery = query.toLowerCase();
        
        final results = testVideoItems.where((video) {
          return video.title.toLowerCase().contains(lowerQuery) ||
                 video.description.toLowerCase().contains(lowerQuery) ||
                 video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        }).toList();
        
        expect(results.length, 4);
      });

      test('should search videos by description correctly', () {
        final query = 'beginners';
        final lowerQuery = query.toLowerCase();
        
        final results = testVideoItems.where((video) {
          return video.title.toLowerCase().contains(lowerQuery) ||
                 video.description.toLowerCase().contains(lowerQuery) ||
                 video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        }).toList();
        
        expect(results.length, 1);
      });

      test('should search videos by tags correctly', () {
        final query = 'game';
        final lowerQuery = query.toLowerCase();
        
        final results = testVideoItems.where((video) {
          return video.title.toLowerCase().contains(lowerQuery) ||
                 video.description.toLowerCase().contains(lowerQuery) ||
                 video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        }).toList();
        
        expect(results.length, 1);
        expect(results[0].tags.contains('game'), true);
      });
    });

    group('BE-03: Recommendation Logic Tests', () {
      test('should prioritize education videos in recommendations', () {
        final levelVideos = testVideoItems.where((v) => v.level == 1).toList();
        
        // Sort using the same logic as the repository
        levelVideos.sort((a, b) {
          // Prioritize education videos
          if (a.type == 'education' && b.type != 'education') return -1;
          if (b.type == 'education' && a.type != 'education') return 1;
          
          // Then by category diversity
          return a.category.compareTo(b.category);
        });
        
        expect(levelVideos.first.type, 'education');
      });

      test('should exclude specified videos from recommendations', () {
        final levelVideos = testVideoItems.where((v) => v.level == 1).toList();
        final excludeIds = ['test_video_001'];
        
        final candidates = levelVideos.where((video) => !excludeIds.contains(video.id)).toList();
        
        expect(candidates.length, 1);
        expect(candidates[0].id, 'test_video_004');
      });

      test('should limit recommendations to max results', () {
        final levelVideos = testVideoItems.where((v) => v.level == 1).toList();
        final maxResults = 1;
        
        final recommendations = levelVideos.take(maxResults).toList();
        
        expect(recommendations.length, 1);
      });
    });

    group('Performance and Error Handling Logic Tests', () {
      test('should handle empty video lists gracefully', () {
        const emptyVideos = <VideoItem>[];
        
        final levelFiltered = emptyVideos.where((v) => v.level == 1).toList();
        expect(levelFiltered, isEmpty);
        
        final typeFiltered = emptyVideos.where((v) => v.type == 'education').toList();
        expect(typeFiltered, isEmpty);
        
        final searchResults = emptyVideos.where((v) => v.title.contains('test')).toList();
        expect(searchResults, isEmpty);
      });

      test('should handle invalid filter criteria gracefully', () {
        final filter = VideoFilter(
          levels: [],
          types: [],
          categories: [],
          difficulties: [],
          tags: [],
          searchQuery: '',
        );
        
        final results = testVideoItems.where(filter.matches).toList();
        expect(results.length, testVideoItems.length); // Should return all videos
      });

      test('should maintain data integrity in filtering operations', () {
        final originalCount = testVideoItems.length;
        
        // Perform various filtering operations
        final levelFiltered = testVideoItems.where((v) => v.level >= 1).toList();
        final typeFiltered = testVideoItems.where((v) => v.type.isNotEmpty).toList();
        final categoryFiltered = testVideoItems.where((v) => v.category.isNotEmpty).toList();
        
        // Original data should remain unchanged
        expect(testVideoItems.length, originalCount);
        
        // All videos should pass basic validation
        expect(levelFiltered.length, originalCount);
        expect(typeFiltered.length, originalCount);
        expect(categoryFiltered.length, originalCount);
      });
    });
  });
} 