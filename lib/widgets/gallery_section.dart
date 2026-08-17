import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/packages_provider.dart';

class GallerySection extends ConsumerStatefulWidget {
  const GallerySection({super.key});

  @override
  ConsumerState<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends ConsumerState<GallerySection> {
  String _selectedCategory = 'all';

  void _showImageLightbox(BuildContext context, Map<String, String> photo) {
    final maxImageHeight = MediaQuery.of(context).size.height * 0.65;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxImageHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: photo['url']!,
                    fit: BoxFit.contain,
                    maxHeightDiskCache: 1200,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                photo['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                photo['location']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppConstants.primaryGold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(galleryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      color: AppConstants.softCream,
      child: Column(
        children: [
          const Text(
            'SACRED PILGRIMAGE GALLERY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Glimpses of Holy Makkah & Madinah',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 24),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CategoryFilterChip(
                  label: 'All Moments',
                  isSelected: _selectedCategory == 'all',
                  onTap: () => setState(() => _selectedCategory = 'all'),
                ),
                const SizedBox(width: 8),
                _CategoryFilterChip(
                  label: 'Makkah Mukarramah',
                  isSelected: _selectedCategory == 'makkah',
                  onTap: () => setState(() => _selectedCategory = 'makkah'),
                ),
                const SizedBox(width: 8),
                _CategoryFilterChip(
                  label: 'Madinah Munawwarah',
                  isSelected: _selectedCategory == 'madinah',
                  onTap: () => setState(() => _selectedCategory = 'madinah'),
                ),
                const SizedBox(width: 8),
                _CategoryFilterChip(
                  label: 'Guided Ziyarat',
                  isSelected: _selectedCategory == 'ziyarat',
                  onTap: () => setState(() => _selectedCategory = 'ziyarat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Photo Gallery Grid
          galleryAsync.when(
            data: (photos) {
              final filtered = _selectedCategory == 'all'
                  ? photos
                  : photos.where((p) => p['category'] == _selectedCategory).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No gallery photos found for selected filter.'),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final crossAxisCount = isWide ? 3 : (constraints.maxWidth > 600 ? 2 : 1);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final photo = filtered[index];
                      return InkWell(
                        onTap: () => _showImageLightbox(context, photo),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: AppTheme.glassCardDecoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: photo['url']!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(color: AppConstants.lightGray),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.75),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 14,
                                  left: 14,
                                  right: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photo['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        photo['location']!,
                                        style: const TextStyle(
                                          color: AppConstants.primaryGold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Positioned(
                                  top: 12,
                                  right: 12,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.black45,
                                    child: Icon(Icons.fullscreen, color: Colors.white, size: 16),
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
            error: (err, stack) => const Text('Could not load photo gallery'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppConstants.primaryGold,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.charcoal : AppConstants.deepGreen,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
