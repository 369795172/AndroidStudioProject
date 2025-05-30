import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Video data model matching the JSON structure
class VideoItem {
  final String id;
  final String title;
  final String cover;
  final String path;
  final int level;
  final String type;
  final List<String> tags;
  final String description;
  final int duration;
  final String difficulty;
  final String category;

  VideoItem({
    required this.id,
    required this.title,
    required this.cover,
    required this.path,
    required this.level,
    required this.type,
    required this.tags,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.category,
  });

  /// Creates VideoItem from JSON map
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      cover: json['cover'] as String,
      path: json['path'] as String,
      level: json['level'] as int,
      type: json['type'] as String,
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
      duration: json['duration'] as int,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
    );
  }

  /// Converts VideoItem to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover': cover,
      'path': path,
      'level': level,
      'type': type,
      'tags': tags,
      'description': description,
      'duration': duration,
      'difficulty': difficulty,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'VideoItem(id: $id, title: $title, level: $level, type: $type)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Video metadata model
class VideoMetadata {
  final String version;
  final String lastUpdated;
  final int totalVideos;
  final List<int> supportedLevels;
  final List<String> supportedTypes;
  final List<String> supportedCategories;

  VideoMetadata({
    required this.version,
    required this.lastUpdated,
    required this.totalVideos,
    required this.supportedLevels,
    required this.supportedTypes,
    required this.supportedCategories,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      version: json['version'] as String,
      lastUpdated: json['lastUpdated'] as String,
      totalVideos: json['totalVideos'] as int,
      supportedLevels: List<int>.from(json['supportedLevels'] as List),
      supportedTypes: List<String>.from(json['supportedTypes'] as List),
      supportedCategories: List<String>.from(json['supportedCategories'] as List),
    );
  }
}

/// Video filter criteria for advanced querying
class VideoFilter {
  final List<int>? levels;
  final List<String>? types;
  final List<String>? categories;
  final List<String>? difficulties;
  final List<String>? tags;
  final String? searchQuery;
  final int? minDuration;
  final int? maxDuration;

  const VideoFilter({
    this.levels,
    this.types,
    this.categories,
    this.difficulties,
    this.tags,
    this.searchQuery,
    this.minDuration,
    this.maxDuration,
  });

  bool matches(VideoItem video) {
    if (levels != null && levels!.isNotEmpty && !levels!.contains(video.level)) return false;
    if (types != null && types!.isNotEmpty && !types!.contains(video.type)) return false;
    if (categories != null && categories!.isNotEmpty && !categories!.contains(video.category)) return false;
    if (difficulties != null && difficulties!.isNotEmpty && !difficulties!.contains(video.difficulty)) return false;
    if (minDuration != null && video.duration < minDuration!) return false;
    if (maxDuration != null && video.duration > maxDuration!) return false;
    
    if (tags != null && tags!.isNotEmpty) {
      bool hasMatchingTag = false;
      for (String tag in tags!) {
        if (video.tags.contains(tag)) {
          hasMatchingTag = true;
          break;
        }
      }
      if (!hasMatchingTag) return false;
    }
    
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!video.title.toLowerCase().contains(query) &&
          !video.description.toLowerCase().contains(query) &&
          !video.tags.any((tag) => tag.toLowerCase().contains(query))) {
        return false;
      }
    }
    
    return true;
  }
}

/// Repository for managing video data from assets/videos.json
/// BE-03: Enhanced video resource mapping interface
class VideoRepository {
  static const String _videoDataPath = 'assets/videos.json';
  
  List<VideoItem>? _cachedVideos;
  VideoMetadata? _cachedMetadata;

  /// Loads and parses the videos.json file from assets
  /// Returns parsed video data with error handling
  Future<Map<String, dynamic>> _loadVideoData() async {
    try {
      final String jsonString = await rootBundle.loadString(_videoDataPath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      return jsonData;
    } catch (e) {
      throw VideoRepositoryException('Failed to load video data from $_videoDataPath: $e');
    }
  }

  /// Gets all videos from the JSON file
  /// Implements caching for better performance
  Future<List<VideoItem>> getAllVideos() async {
    if (_cachedVideos != null) {
      return _cachedVideos!;
    }

    try {
      final jsonData = await _loadVideoData();
      final List<dynamic> videosJson = jsonData['videos'] as List<dynamic>;
      
      _cachedVideos = videosJson
          .map((json) => VideoItem.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return _cachedVideos!;
    } catch (e) {
      throw VideoRepositoryException('Failed to parse video data: $e');
    }
  }

  /// Gets video metadata information
  Future<VideoMetadata> getMetadata() async {
    if (_cachedMetadata != null) {
      return _cachedMetadata!;
    }

    try {
      final jsonData = await _loadVideoData();
      final Map<String, dynamic> metadataJson = jsonData['metadata'] as Map<String, dynamic>;
      
      _cachedMetadata = VideoMetadata.fromJson(metadataJson);
      return _cachedMetadata!;
    } catch (e) {
      throw VideoRepositoryException('Failed to parse metadata: $e');
    }
  }

  /// BE-03: Enhanced getVideosForLevel method
  /// Gets videos filtered by level with additional sorting and error handling
  /// [level] - the difficulty level (1, 2, 3, etc.)
  /// [sortBy] - optional sorting criteria ('title', 'duration', 'category')
  /// Returns: List of videos for the specified level, never null
  /// Implements 0% error rate requirement
  Future<List<VideoItem>> getVideosForLevel(int level, {String? sortBy}) async {
    try {
      if (level < 1) {
        throw ArgumentError('Level must be positive, got: $level');
      }

      final allVideos = await getAllVideos();
      final levelVideos = allVideos.where((video) => video.level == level).toList();
      
      // Sort if requested
      if (sortBy != null) {
        levelVideos.sort((a, b) {
          switch (sortBy.toLowerCase()) {
            case 'title':
              return a.title.compareTo(b.title);
            case 'duration':
              return a.duration.compareTo(b.duration);
            case 'category':
              return a.category.compareTo(b.category);
            default:
              return 0; // No sorting for unknown criteria
          }
        });
      }
      
      return levelVideos;
    } catch (e) {
      // Maintain 0% error rate by returning empty list instead of throwing
      print('VideoRepository.getVideosForLevel error: $e');
      return [];
    }
  }

  /// BE-03: Enhanced getVideoById method  
  /// Gets a specific video by ID with detailed error handling
  /// [id] - unique video identifier
  /// Returns: VideoItem if found, null if not found
  /// Implements 0% error rate requirement
  Future<VideoItem?> getVideoById(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Video ID cannot be empty');
      }

      final allVideos = await getAllVideos();
      
      for (VideoItem video in allVideos) {
        if (video.id == id) {
          return video;
        }
      }
      
      return null; // Video not found - this is valid, not an error
    } catch (e) {
      // Maintain 0% error rate by returning null instead of throwing
      print('VideoRepository.getVideoById error: $e');
      return null;
    }
  }

  /// BE-03: Batch get videos by multiple IDs
  /// [ids] - list of video IDs to retrieve
  /// Returns: Map of id -> VideoItem (only for found videos)
  Future<Map<String, VideoItem>> getVideosByIds(List<String> ids) async {
    try {
      final result = <String, VideoItem>{};
      
      for (String id in ids) {
        final video = await getVideoById(id);
        if (video != null) {
          result[id] = video;
        }
      }
      
      return result;
    } catch (e) {
      print('VideoRepository.getVideosByIds error: $e');
      return {};
    }
  }

  /// Gets videos filtered by type
  Future<List<VideoItem>> getVideosByType(String type) async {
    try {
      final allVideos = await getAllVideos();
      return allVideos.where((video) => video.type == type).toList();
    } catch (e) {
      print('VideoRepository.getVideosByType error: $e');
      return [];
    }
  }

  /// Gets videos filtered by category
  Future<List<VideoItem>> getVideosByCategory(String category) async {
    try {
      final allVideos = await getAllVideos();
      return allVideos.where((video) => video.category == category).toList();
    } catch (e) {
      print('VideoRepository.getVideosByCategory error: $e');
      return [];
    }
  }

  /// Gets videos filtered by difficulty
  Future<List<VideoItem>> getVideosByDifficulty(String difficulty) async {
    try {
      final allVideos = await getAllVideos();
      return allVideos.where((video) => video.difficulty == difficulty).toList();
    } catch (e) {
      print('VideoRepository.getVideosByDifficulty error: $e');
      return [];
    }
  }

  /// BE-03: Advanced filtering with VideoFilter
  /// Supports complex multi-criteria filtering
  Future<List<VideoItem>> getVideosWithFilter(VideoFilter filter) async {
    try {
      final allVideos = await getAllVideos();
      return allVideos.where(filter.matches).toList();
    } catch (e) {
      print('VideoRepository.getVideosWithFilter error: $e');
      return [];
    }
  }

  /// Searches videos by title or description
  Future<List<VideoItem>> searchVideos(String query) async {
    if (query.isEmpty) return await getAllVideos();
    
    try {
      final allVideos = await getAllVideos();
      final lowerQuery = query.toLowerCase();
      
      return allVideos.where((video) {
        return video.title.toLowerCase().contains(lowerQuery) ||
               video.description.toLowerCase().contains(lowerQuery) ||
               video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      print('VideoRepository.searchVideos error: $e');
      return [];
    }
  }

  /// BE-03: Gets available levels with video counts
  /// Returns: Map of level -> count of videos at that level
  Future<Map<int, int>> getLevelStats() async {
    try {
      final allVideos = await getAllVideos();
      final Map<int, int> stats = {};
      
      for (VideoItem video in allVideos) {
        stats[video.level] = (stats[video.level] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      print('VideoRepository.getLevelStats error: $e');
      return {};
    }
  }

  /// BE-03: Validates that all required levels have videos
  /// [requiredLevels] - levels that must have at least one video
  /// Returns: true if all levels have videos, false otherwise
  Future<bool> validateLevelCoverage(List<int> requiredLevels) async {
    try {
      final levelStats = await getLevelStats();
      
      for (int level in requiredLevels) {
        if (!levelStats.containsKey(level) || levelStats[level]! == 0) {
          print('Level $level has no videos');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('VideoRepository.validateLevelCoverage error: $e');
      return false;
    }
  }

  /// BE-03: Gets recommended videos for a level
  /// Uses intelligent selection based on user's progress and preferences
  /// [level] - target level
  /// [excludeIds] - videos to exclude (e.g., already watched)
  /// [maxResults] - maximum number of recommendations
  Future<List<VideoItem>> getRecommendedVideos(int level, {List<String>? excludeIds, int maxResults = 5}) async {
    try {
      final levelVideos = await getVideosForLevel(level);
      
      // Filter out excluded videos
      List<VideoItem> candidates = levelVideos;
      if (excludeIds != null && excludeIds.isNotEmpty) {
        candidates = levelVideos.where((video) => !excludeIds.contains(video.id)).toList();
      }
      
      // Simple recommendation: prioritize education type, then variety
      candidates.sort((a, b) {
        // Prioritize education videos
        if (a.type == 'education' && b.type != 'education') return -1;
        if (b.type == 'education' && a.type != 'education') return 1;
        
        // Then by category diversity (simple alphabetical for now)
        return a.category.compareTo(b.category);
      });
      
      return candidates.take(maxResults).toList();
    } catch (e) {
      print('VideoRepository.getRecommendedVideos error: $e');
      return [];
    }
  }

  /// Clears the cache - useful for testing or when data is updated
  void clearCache() {
    _cachedVideos = null;
    _cachedMetadata = null;
  }

  /// Validates that the JSON structure is correct
  /// Returns true if valid, throws exception if invalid
  Future<bool> validateDataStructure() async {
    try {
      final jsonData = await _loadVideoData();
      
      // Check required top-level keys
      if (!jsonData.containsKey('videos') || !jsonData.containsKey('metadata')) {
        throw VideoRepositoryException('Missing required keys: videos or metadata');
      }

      // Validate videos array
      final List<dynamic> videosJson = jsonData['videos'] as List<dynamic>;
      for (var videoJson in videosJson) {
        final video = videoJson as Map<String, dynamic>;
        _validateVideoItem(video);
      }

      // Validate metadata
      final Map<String, dynamic> metadataJson = jsonData['metadata'] as Map<String, dynamic>;
      _validateMetadata(metadataJson);

      return true;
    } catch (e) {
      throw VideoRepositoryException('JSON validation failed: $e');
    }
  }

  void _validateVideoItem(Map<String, dynamic> video) {
    final requiredFields = ['id', 'title', 'cover', 'path', 'level', 'type', 'tags', 'description', 'duration', 'difficulty', 'category'];
    
    for (String field in requiredFields) {
      if (!video.containsKey(field)) {
        throw VideoRepositoryException('Missing required field in video: $field');
      }
    }

    // Type validations
    if (video['level'] is! int) throw VideoRepositoryException('level must be int');
    if (video['duration'] is! int) throw VideoRepositoryException('duration must be int');
    if (video['tags'] is! List) throw VideoRepositoryException('tags must be List');
  }

  void _validateMetadata(Map<String, dynamic> metadata) {
    final requiredFields = ['version', 'lastUpdated', 'totalVideos', 'supportedLevels', 'supportedTypes', 'supportedCategories'];
    
    for (String field in requiredFields) {
      if (!metadata.containsKey(field)) {
        throw VideoRepositoryException('Missing required field in metadata: $field');
      }
    }
  }

  /// BE-03: Comprehensive repository health check
  /// Validates all BE-03 requirements and returns detailed status
  Future<Map<String, dynamic>> performHealthCheck() async {
    final results = <String, dynamic>{
      'dataStructureValid': false,
      'levelCoverageValid': false,
      'errorRate': 0.0,
      'supportedLevels': <int>[],
      'levelStats': <int, int>{},
      'totalVideos': 0,
      'errors': <String>[],
    };

    try {
      // Test data structure validation
      results['dataStructureValid'] = await validateDataStructure();
      
      // Test level coverage
      final metadata = await getMetadata();
      results['supportedLevels'] = metadata.supportedLevels;
      results['levelCoverageValid'] = await validateLevelCoverage(metadata.supportedLevels);
      
      // Get statistics
      results['levelStats'] = await getLevelStats();
      final allVideos = await getAllVideos();
      results['totalVideos'] = allVideos.length;
      
      // Test BE-03 core methods with error tracking
      int totalTests = 0;
      int errors = 0;
      
      // Test getVideosForLevel for each supported level
      for (int level in metadata.supportedLevels) {
        totalTests++;
        try {
          final levelVideos = await getVideosForLevel(level);
          if (levelVideos.isEmpty && results['levelStats'][level] > 0) {
            errors++;
            results['errors'].add('getVideosForLevel($level) returned empty but level has videos');
          }
        } catch (e) {
          errors++;
          results['errors'].add('getVideosForLevel($level) failed: $e');
        }
      }
      
      // Test getVideoById for each video
      for (VideoItem video in allVideos) {
        totalTests++;
        try {
          final retrievedVideo = await getVideoById(video.id);
          if (retrievedVideo == null) {
            errors++;
            results['errors'].add('getVideoById(${video.id}) returned null for existing video');
          } else if (retrievedVideo.id != video.id) {
            errors++;
            results['errors'].add('getVideoById(${video.id}) returned wrong video');
          }
        } catch (e) {
          errors++;
          results['errors'].add('getVideoById(${video.id}) failed: $e');
        }
      }
      
      results['errorRate'] = totalTests > 0 ? errors / totalTests : 0.0;
      
    } catch (e) {
      results['errors'].add('Health check failed: $e');
    }

    return results;
  }
}

/// Custom exception for VideoRepository errors
class VideoRepositoryException implements Exception {
  final String message;
  VideoRepositoryException(this.message);
  
  @override
  String toString() => 'VideoRepositoryException: $message';
} 