import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import 'supabase_provider.dart';

final videosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final crudList = ref.watch(videosCrudNotifierProvider);

  final supabase = ref.watch(supabaseClientProvider);
  if (supabase != null) {
    try {
      final data = await supabase.from('videos').select().eq('is_active', true).order('created_at', ascending: false);
      if ((data as List).isNotEmpty) {
        final list = (data).map((e) => VideoModel.fromJson(e)).toList();
        final existingIds = list.map((e) => e.id).toSet();
        final localAdded = crudList.where((v) => !existingIds.contains(v.id)).toList();
        return [...localAdded, ...list];
      }
    } catch (_) {}
  }

  // Fallback seed YouTube videos
  final seedVideos = [
    VideoModel(
      id: 'v1',
      title: 'Jamal Tours Executive Umrah Group Experience 2026',
      youtubeUrl: 'https://www.youtube.com/watch?v=5Eqb_-j3FDA',
      videoId: '5Eqb_-j3FDA',
      category: 'vlog',
      createdAt: DateTime.now(),
    ),
    VideoModel(
      id: 'v2',
      title: 'Step by Step Umrah Guide & Rituals Explanation by Scholar',
      youtubeUrl: 'https://www.youtube.com/watch?v=5Eqb_-j3FDA',
      videoId: '5Eqb_-j3FDA',
      category: 'guidance',
      createdAt: DateTime.now(),
    ),
    VideoModel(
      id: 'v3',
      title: 'Madinah Munawwarah Historical Ziyarat Tour Overview',
      youtubeUrl: 'https://www.youtube.com/watch?v=5Eqb_-j3FDA',
      videoId: '5Eqb_-j3FDA',
      category: 'ziyarat',
      createdAt: DateTime.now(),
    ),
  ];

  final existingIds = seedVideos.map((e) => e.id).toSet();
  final localAdded = crudList.where((v) => !existingIds.contains(v.id)).toList();
  return [...localAdded, ...seedVideos];
});

class VideosCrudNotifier extends StateNotifier<List<VideoModel>> {
  VideosCrudNotifier() : super([]);

  void addVideo(VideoModel video) {
    state = [video, ...state];
  }

  void deleteVideo(String id) {
    state = state.where((v) => v.id != id).toList();
  }
}

final videosCrudNotifierProvider =
    StateNotifierProvider<VideosCrudNotifier, List<VideoModel>>((ref) {
  return VideosCrudNotifier();
});
