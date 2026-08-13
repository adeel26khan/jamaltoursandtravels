import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/video_model.dart';
import '../providers/videos_provider.dart';

class VideosSection extends ConsumerWidget {
  const VideosSection({super.key});

  void _openYouTubeVideo(BuildContext context, VideoModel video) async {
    final Uri uri = Uri.parse(video.youtubeUrl.isNotEmpty
        ? video.youtubeUrl
        : 'https://www.youtube.com/watch?v=${video.videoId}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${video.youtubeUrl}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videosProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'OFFICIAL YOUTUBE VLOGS & GUIDANCE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Experience Our Sacred Journey Videos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Watch pilgrim group experiences, Umrah guidance seminars, and historical Makkah & Madinah Ziyarat vlogs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppConstants.charcoal.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 36),

          videosAsync.when(
            data: (videos) {
              if (videos.isEmpty) {
                return const SizedBox();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final crossAxisCount = isWide ? 3 : (constraints.maxWidth > 580 ? 2 : 1);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return InkWell(
                        onTap: () => _openYouTubeVideo(context, video),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: AppTheme.glassCardDecoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Thumbnail Image
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(color: AppConstants.lightGray),
                                    errorWidget: (context, url, err) => Container(
                                      color: AppConstants.deepGreen,
                                      child: const Icon(Icons.play_circle_fill, color: AppConstants.primaryGold, size: 50),
                                    ),
                                  ),
                                ),
                                // Gradient Overlay
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Red YouTube Play Button Badge
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
                                    ),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                                  ),
                                ),
                                // Title & Category Tag
                                Positioned(
                                  bottom: 14,
                                  left: 14,
                                  right: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppConstants.primaryGold,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          video.category.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppConstants.charcoal,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        video.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
            error: (err, stack) => const Text('Could not load videos list'),
          ),
        ],
      ),
    );
  }
}
