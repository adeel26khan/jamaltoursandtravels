import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/responsive_utils.dart';
import '../providers/packages_provider.dart';

class TestimonialsSection extends ConsumerWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testimonialsAsync = ref.watch(testimonialsProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      color: AppConstants.deepGreen.withValues(alpha: 0.03),
      padding: EdgeInsets.symmetric(
        vertical: 48,
        horizontal: isDesktop ? 60 : 24,
      ),
      child: Column(
        children: [
          const Text(
            'PILGRIM TESTIMONIALS',
            style: TextStyle(
              color: AppConstants.primaryGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Words From Blessed Travelers',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 32),

          testimonialsAsync.when(
            data: (testimonials) {
              if (testimonials.isEmpty) {
                return const Text('No testimonials available.');
              }

              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: testimonials.length,
                  itemBuilder: (context, index) {
                    final item = testimonials[index];
                    return Container(
                      width: isDesktop ? 360 : 300,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppConstants.primaryGold,
                                backgroundImage: item.avatarUrl != null
                                    ? CachedNetworkImageProvider(item.avatarUrl!)
                                    : null,
                                child: item.avatarUrl == null
                                    ? Text(
                                        item.name[0],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.charcoal,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppConstants.deepGreen,
                                      ),
                                    ),
                                    Text(
                                      item.city,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.charcoal.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(
                              item.rating,
                              (i) => const Icon(
                                Icons.star,
                                color: AppConstants.primaryGold,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              '"${item.comment}"',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppConstants.charcoal.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: AppConstants.primaryGold),
              ),
            ),
            error: (err, stack) => const Text('Could not load testimonials.'),
          ),
        ],
      ),
    );
  }
}
