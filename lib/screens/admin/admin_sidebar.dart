import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../widgets/app_logo.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectTab;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppConstants.deepGreen,
      child: Column(
        children: [
          // Header Branding
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const AppLogo(size: 32, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'ADMIN PANEL',
                        style: AppTheme.islamicAccentStyle(
                          fontSize: 10,
                          color: AppConstants.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppConstants.borderGold, height: 1),
          const SizedBox(height: 16),

          // Navigation Links
          _NavItem(
            icon: Icons.dashboard,
            title: 'Overview',
            isSelected: selectedIndex == 0,
            onTap: () => onSelectTab(0),
          ),
          _NavItem(
            icon: Icons.mosque,
            title: 'Packages CRUD',
            isSelected: selectedIndex == 1,
            onTap: () => onSelectTab(1),
          ),
          _NavItem(
            icon: Icons.book_online,
            title: 'Bookings Manager',
            isSelected: selectedIndex == 2,
            onTap: () => onSelectTab(2),
          ),
          _NavItem(
            icon: Icons.question_answer,
            title: 'Enquiries Tracker',
            isSelected: selectedIndex == 3,
            onTap: () => onSelectTab(3),
          ),
          _NavItem(
            icon: Icons.hotel,
            title: 'Hotels & Haram',
            isSelected: selectedIndex == 4,
            onTap: () => onSelectTab(4),
          ),
          _NavItem(
            icon: Icons.rate_review,
            title: 'Testimonials',
            isSelected: selectedIndex == 5,
            onTap: () => onSelectTab(5),
          ),
          _NavItem(
            icon: Icons.video_library,
            title: 'YouTube Videos',
            isSelected: selectedIndex == 6,
            onTap: () => onSelectTab(6),
          ),

          const Spacer(),
          const Divider(color: AppConstants.borderGold, height: 1),

          // Back to Main Website Button
          ListTile(
            leading: const Icon(Icons.arrow_back, color: AppConstants.primaryGold),
            title: const Text(
              'Back to Website',
              style: TextStyle(color: AppConstants.warmWhite, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onTap: () => context.go('/'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppConstants.primaryGold : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppConstants.charcoal : AppConstants.warmWhite),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppConstants.charcoal : AppConstants.warmWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
