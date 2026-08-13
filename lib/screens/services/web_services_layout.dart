import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/app_footer.dart';

class WebServicesLayout extends StatelessWidget {
  const WebServicesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebNavbar(activeRoute: '/services'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
              color: AppConstants.deepGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Home  /  Our Services', style: TextStyle(color: AppConstants.primaryGold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'Comprehensive Hajj, Umrah & Travel Services',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'End-to-end pilgrimage management, visa assistance, direct air tickets, and 5-star hotel reservations.',
                    style: TextStyle(
                      color: AppConstants.warmWhite.withValues(alpha: 0.85),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // 4-Column Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 48),
              child: Column(
                children: [
                  const Text(
                    'SPECIALIZED TRAVEL SERVICES',
                    style: TextStyle(color: AppConstants.primaryGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Everything You Need for a Seamless Sacred Journey',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                  ),
                  const SizedBox(height: 40),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: AppConstants.services.length,
                    itemBuilder: (context, index) {
                      final item = AppConstants.services[index];
                      return _WebServiceCard(
                        title: item['title']!,
                        desc: item['desc']!,
                        icon: _getIconData(item['icon']!),
                      ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'kaaba':
        return Icons.mosque;
      case 'moon':
        return Icons.nightlight_round;
      case 'plane':
        return Icons.flight;
      case 'passport':
        return Icons.badge;
      case 'hotel':
        return Icons.apartment;
      case 'shield':
        return Icons.security;
      case 'money':
        return Icons.payments;
      case 'map':
        return Icons.map;
      default:
        return Icons.travel_explore;
    }
  }
}

class _WebServiceCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _WebServiceCard({
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  State<_WebServiceCard> createState() => _WebServiceCardState();
}

class _WebServiceCardState extends State<_WebServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isHovered ? AppConstants.deepGreen : AppConstants.warmWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppConstants.primaryGold : AppConstants.borderGold,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.deepGreen.withValues(alpha: _isHovered ? 0.2 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isHovered ? AppConstants.primaryGold : AppConstants.deepGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isHovered ? AppConstants.deepGreen : AppConstants.primaryGold,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _isHovered ? AppConstants.warmWhite : AppConstants.deepGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.desc,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: _isHovered ? AppConstants.warmWhite.withValues(alpha: 0.85) : AppConstants.charcoal.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => context.push('/enquiry?service=${Uri.encodeComponent(widget.title)}'),
              child: Row(
                children: [
                  Text(
                    'ENQUIRE NOW',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? AppConstants.primaryGold : AppConstants.deepGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: _isHovered ? AppConstants.primaryGold : AppConstants.deepGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
