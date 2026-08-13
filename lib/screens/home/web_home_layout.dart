import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../providers/packages_provider.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/hero_carousel.dart';
import '../../widgets/trust_bar.dart';
import '../../widgets/package_card.dart';
import '../../widgets/why_choose_us.dart';
import '../../widgets/gallery_section.dart';
import '../../widgets/videos_section.dart';
import '../../widgets/testimonials_section.dart';
import '../../widgets/app_footer.dart';

class WebHomeLayout extends ConsumerWidget {
  const WebHomeLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider);

    return Scaffold(
      appBar: const WebNavbar(activeRoute: '/'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Full-Width Hero Carousel
            const HeroCarousel(),

            // 2. Trust Metrics Bar
            const TrustBar().animate().fadeIn(duration: 500.ms),

            // 3. Featured Packages Grid Section (Responsive Wrap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                children: [
                  const Text(
                    'SACRED PILGRIMAGE PACKAGES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryGold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Featured Hajj & Ramzan Packages',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                        ),
                  ),
                  const SizedBox(height: 36),

                  packagesAsync.when(
                    data: (packages) {
                      final featuredList = packages.take(6).toList();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final is3Col = width > 980;
                          final is2Col = width > 620 && width <= 980;
                          final spacing = 20.0;
                          final cardWidth = is3Col
                              ? (width - (spacing * 2)) / 3
                              : (is2Col ? (width - spacing) / 2 : width);

                          return Wrap(
                            spacing: spacing,
                            runSpacing: 24,
                            children: featuredList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final pkg = entry.value;
                              return SizedBox(
                                width: cardWidth,
                                child: PackageCard(package: pkg)
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                                    .slideY(begin: 0.08, end: 0),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppConstants.primaryGold),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text('Error loading packages: $err'),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Why Choose Us
            const WhyChooseUs(),

            // 5. Sacred Pilgrimage Photo Gallery
            const GallerySection(),

            // 6. YouTube Channel Vlogs & Guidance
            const VideosSection(),

            // 7. Testimonials Section
            const TestimonialsSection(),

            // 8. Rich Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
