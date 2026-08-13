import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../models/video_model.dart';
import '../../providers/videos_provider.dart';
import '../../providers/supabase_provider.dart';

class AdminVideosManager extends ConsumerWidget {
  const AdminVideosManager({super.key});

  void _showAddVideoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String selectedCategory = 'vlog';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.softCream,
        title: const Text('Add YouTube Channel Video', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Video Title *',
                  hintText: 'e.g. Ramzan 2026 Umrah Group Tour Vlog',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video Link *',
                  hintText: 'https://www.youtube.com/watch?v=... or https://youtu.be/...',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'vlog', child: Text('Tour Vlog / Review')),
                  DropdownMenuItem(value: 'guidance', child: Text('Umrah / Hajj Guidance')),
                  DropdownMenuItem(value: 'ziyarat', child: Text('Makkah & Madinah Ziyarat')),
                ],
                onChanged: (val) => selectedCategory = val ?? 'vlog',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final inputUrl = urlController.text.trim();
                final extractedId = VideoModel.extractVideoId(inputUrl);

                final newVideo = VideoModel(
                  id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  youtubeUrl: inputUrl,
                  videoId: extractedId,
                  category: selectedCategory,
                  createdAt: DateTime.now(),
                );

                final supabase = ref.read(supabaseClientProvider);
                if (supabase != null) {
                  try {
                    await supabase.from('videos').insert({
                      'title': newVideo.title,
                      'youtube_url': newVideo.youtubeUrl,
                      'video_id': newVideo.videoId,
                      'category': newVideo.category,
                    });
                  } catch (_) {}
                }

                ref.read(videosCrudNotifierProvider.notifier).addVideo(newVideo);
                ref.invalidate(videosProvider);
                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('YouTube video added & saved to database!'),
                    backgroundColor: AppConstants.deepGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGold, foregroundColor: AppConstants.charcoal),
            child: const Text('ADD VIDEO', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videosProvider);
    final isDesktop = ResponsiveUtils.isWebDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YouTube Channel Videos Manager',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                          fontSize: isDesktop ? 24 : 20,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Add YouTube video links from your channel to showcase tour vlogs & Umrah guidance.'),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddVideoDialog(context, ref),
                icon: const Icon(Icons.video_call, color: AppConstants.charcoal),
                label: const Text('ADD YOUTUBE VIDEO', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: AppConstants.charcoal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          videosAsync.when(
            data: (videos) {
              if (videos.isEmpty) {
                return const Center(child: Text('No YouTube videos added yet. Click "Add YouTube Video" above.'));
              }

              return Container(
                width: double.infinity,
                decoration: AppTheme.glassCardDecoration(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Thumbnail', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Video ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: videos.map((video) {
                      return DataRow(cells: [
                        DataCell(
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              video.thumbnailUrl,
                              width: 60,
                              height: 38,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Icon(Icons.ondemand_video, color: Colors.red),
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(Text(video.category.toUpperCase())),
                        DataCell(Text(video.videoId)),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            tooltip: 'Delete Video',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppConstants.softCream,
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                                      SizedBox(width: 8),
                                      Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    ],
                                  ),
                                  content: Text('Are you sure you want to delete "${video.title}" from YouTube Videos?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final supabase = ref.read(supabaseClientProvider);
                                        if (supabase != null) {
                                          try {
                                            await supabase.from('videos').delete().eq('id', video.id);
                                          } catch (_) {}
                                        }

                                        ref.read(videosCrudNotifierProvider.notifier).deleteVideo(video.id);
                                        ref.invalidate(videosProvider);
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Removed ${video.title}')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                      child: const Text('DELETE VIDEO', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
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
