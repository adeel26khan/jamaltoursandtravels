import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/responsive_utils.dart';

class WhyChooseUs extends StatelessWidget {
  const WhyChooseUs({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    final features = [
      {
        'icon': Icons.verified,
        'title': 'Licensed Tour Operator',
        'desc': 'Government recognized operator with transparent terms & 100% legal compliance.',
      },
      {
        'icon': Icons.apartment,
        'title': 'Luxury Hotels Near Haram',
        'desc': '5-Star accommodations located within short walking distance of Kaaba & Prophet\'s Mosque.',
      },
      {
        'icon': Icons.flight_takeoff,
        'title': 'Direct Flight Connections',
        'desc': 'Top airline partners with generous baggage allowances & comfortable AC coaches.',
      },
      {
        'icon': Icons.record_voice_over,
        'title': 'Personal Guide & Scholar',
        'desc': 'Qualified Islamic scholars guiding every ritual, Tawaf, Sa\'i, and historical Ziyarat.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 48,
        horizontal: isDesktop ? 60 : 24,
      ),
      child: Column(
        children: [
          // Section Heading
          Text(
            'WHY CHOOSE JAMAL TOURS',
            style: TextStyle(
              color: AppConstants.primaryGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sacred Journeys Built on Trust',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 36),

          // Features Grid / List
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  children: features
                      .map((f) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: _FeatureCard(feature: f),
                            ),
                          ))
                      .toList(),
                );
              } else if (constraints.maxWidth > 550) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: features.map((f) => _FeatureCard(feature: f)).toList(),
                );
              } else {
                return Column(
                  children: features
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _FeatureCard(feature: f),
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Map<String, dynamic> feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.deepGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: AppConstants.primaryGold,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feature['title'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature['desc'] as String,
            style: TextStyle(
              fontSize: 13,
              color: AppConstants.charcoal.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
