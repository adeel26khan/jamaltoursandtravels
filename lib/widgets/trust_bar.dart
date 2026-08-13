import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/responsive_utils.dart';

class TrustBar extends StatelessWidget {
  const TrustBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    final metrics = [
      {'icon': Icons.verified_user, 'title': '10+ Years', 'subtitle': 'Trusted Experience'},
      {'icon': Icons.groups, 'title': '50,000+', 'subtitle': 'Happy Pilgrims'},
      {'icon': Icons.workspace_premium, 'title': 'Govt Approved', 'subtitle': 'GST Registered'},
      {'icon': Icons.support_agent, 'title': '24/7 Support', 'subtitle': 'On-Ground Scholar Assistance'},
    ];

    return Container(
      color: AppConstants.deepGreen,
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: isDesktop ? 60 : 16,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppConstants.warmWhite.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.primaryGold.withValues(alpha: 0.3),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: metrics
                    .map((m) => _MetricTile(
                          icon: m['icon'] as IconData,
                          title: m['title'] as String,
                          subtitle: m['subtitle'] as String,
                        ))
                    .toList(),
              );
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: metrics
                  .map((m) => _MetricTile(
                        icon: m['icon'] as IconData,
                        title: m['title'] as String,
                        subtitle: m['subtitle'] as String,
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MetricTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConstants.primaryGold.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: AppConstants.primaryGold, size: 24),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppConstants.warmWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppConstants.warmWhite.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
