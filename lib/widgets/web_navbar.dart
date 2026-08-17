import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';

class WebNavbar extends ConsumerWidget implements PreferredSizeWidget {
  final String activeRoute;

  const WebNavbar({super.key, this.activeRoute = '/'});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: AppConstants.deepGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(color: AppConstants.primaryGold, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          // Logo & Brand Name
          InkWell(
            onTap: () => context.go('/'),
            child: Row(
              children: [
                const AppLogo(),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppConstants.warmWhite,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                    Text(
                      'HAJJ & UMRAH SPECIALIST',
                      style: AppTheme.islamicAccentStyle(
                        fontSize: 10,
                        color: AppConstants.primaryGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          // Navigation Links
          _NavLink(title: 'Home', route: '/', isActive: activeRoute == '/'),
          _NavLink(title: 'Packages', route: '/packages', isActive: activeRoute.startsWith('/packages')),
          _NavLink(title: 'Services', route: '/services', isActive: activeRoute == '/services'),
          _NavLink(title: 'Contact', route: '/enquiry', isActive: activeRoute == '/enquiry'),

          const SizedBox(width: 24),

          // Enquire Now Gold CTA Button
          ElevatedButton.icon(
            onPressed: () => context.push('/enquiry'),
            icon: const Icon(Icons.send, size: 16, color: AppConstants.charcoal),
            label: const Text('ENQUIRE NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGold,
              foregroundColor: AppConstants.charcoal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
          const SizedBox(width: 16),

          // Auth / Profile Button
          if (authState.isAuthenticated)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') {
                  context.push('/profile');
                } else if (value == 'admin') {
                  context.push('/admin');
                } else if (value == 'logout') {
                  ref.read(authProvider.notifier).signOut();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: AppConstants.deepGreen),
                      const SizedBox(width: 8),
                      Text(authState.profile?.fullName ?? 'My Profile'),
                    ],
                  ),
                ),
                if (authState.isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard, size: 18, color: AppConstants.primaryGold),
                        SizedBox(width: 8),
                        Text('Admin Dashboard'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.warmWhite.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstants.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, color: AppConstants.primaryGold, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      authState.profile?.fullName?.split(' ').first ?? 'Account',
                      style: const TextStyle(color: AppConstants.warmWhite, fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppConstants.primaryGold, size: 18),
                  ],
                ),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => context.push('/login'),
              icon: const Icon(Icons.login, size: 16, color: AppConstants.primaryGold),
              label: const Text('Login'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppConstants.primaryGold),
                foregroundColor: AppConstants.primaryGold,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final String route;
  final bool isActive;

  const _NavLink({
    required this.title,
    required this.route,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppConstants.primaryGold : AppConstants.warmWhite.withValues(alpha: 0.9),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: isActive ? 24 : 0,
              color: AppConstants.primaryGold,
            ),
          ],
        ),
      ),
    );
  }
}
