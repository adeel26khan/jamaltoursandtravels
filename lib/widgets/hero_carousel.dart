import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/responsive_utils.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Blessed Ramzan & Hajj 2026 Pilgrimage',
      'subtitle': 'Experience pure spiritual devotion in Makkah Mukarramah & Madinah Munawwarah with 5-Star Haram facing hotels.',
      'image': 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=1600&q=80',
      'arabic': 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ',
    },
    {
      'title': 'Peaceful Journeys to Masjid An-Nabawi',
      'subtitle': 'Walk in the footsteps of the Prophet ﷺ with dedicated scholars, direct flights, and full logistics support.',
      'image': 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1600&q=80',
      'arabic': 'مُحَمَّدٌ رَسُولُ اللَّهِ',
    },
    {
      'title': 'Trusted Hajj & Umrah Tour Operator',
      'subtitle': '10+ Years of Excellence serving pilgrims from Thane & Mumbai. Transparent pricing with zero hidden fees.',
      'image': 'https://images.unsplash.com/photo-1542816417-0983cbe32277?auto=format&fit=crop&w=1600&q=80',
      'arabic': 'وَأَتِمُّوا الْحَجَّ وَالْعُمْرَةَ لِلَّهِ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentIndex < _slides.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final heroHeight = isDesktop ? 550.0 : 460.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          // Carousel Slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                children: [
                  // Image
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: slide['image']!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppConstants.deepGreen),
                      errorWidget: (context, url, error) => Container(color: AppConstants.deepGreen),
                    ),
                  ),

                  // Dark Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Text Box
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide['arabic']!,
                            style: AppTheme.islamicAccentStyle(
                              fontSize: isDesktop ? 32 : 22,
                              color: AppConstants.primaryGold,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          SizedBox(height: isDesktop ? 12 : 8),

                          Text(
                            slide['title']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppConstants.warmWhite,
                                  fontSize: isDesktop ? 42 : 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                          ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms),
                          SizedBox(height: isDesktop ? 16 : 8),

                          Text(
                            slide['subtitle']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppConstants.warmWhite.withValues(alpha: 0.9),
                              fontSize: isDesktop ? 18 : 13,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 28 : 16),

                          // CTAs
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => context.go('/packages'),
                                icon: const Icon(Icons.explore, color: AppConstants.charcoal, size: 18),
                                label: const Text('EXPLORE PACKAGES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryGold,
                                  foregroundColor: AppConstants.charcoal,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 28 : 16,
                                    vertical: isDesktop ? 18 : 12,
                                  ),
                                ),
                              ).animate().scale(duration: 300.ms, delay: 200.ms),

                              OutlinedButton.icon(
                                onPressed: () => context.push('/enquiry'),
                                icon: const Icon(Icons.headset_mic, color: AppConstants.primaryGold, size: 18),
                                label: const Text('INSTANT INQUIRY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppConstants.primaryGold, width: 2),
                                  foregroundColor: AppConstants.warmWhite,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 24 : 16,
                                    vertical: isDesktop ? 18 : 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Slide Indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 28 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppConstants.primaryGold
                        : AppConstants.warmWhite.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
