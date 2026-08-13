class VideoModel {
  final String id;
  final String title;
  final String youtubeUrl;
  final String videoId;
  final String category;
  final bool isActive;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.videoId,
    this.category = 'vlog',
    this.isActive = true,
    required this.createdAt,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  static String extractVideoId(String url) {
    final regExp = RegExp(
      r'^.*(?:youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return url;
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Pilgrimage Vlog',
      youtubeUrl: json['youtube_url'] as String? ?? '',
      videoId: json['video_id'] as String? ?? extractVideoId(json['youtube_url'] as String? ?? ''),
      category: json['category'] as String? ?? 'vlog',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'youtube_url': youtubeUrl,
      'video_id': videoId,
      'category': category,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
