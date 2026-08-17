import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/packages_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/hero_carousel.dart';
import '../../widgets/package_card.dart';
import '../../widgets/why_choose_us.dart';
import '../../widgets/gallery_section.dart';
import '../../widgets/videos_section.dart';
import '../../widgets/testimonials_section.dart';
import '../../widgets/mobile_bottom_nav.dart';
import '../../widgets/app_logo.dart';

class MobileHomeLayout extends ConsumerWidget {
  const MobileHomeLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider);
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.deepGreen,
        elevation: 2,
        title: Row(
          children: [
            const AppLogo(size: 28, borderRadius: 6),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.warmWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppConstants.primaryGold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hajj 2026 pre-registrations are now open!'),
                  backgroundColor: AppConstants.deepGreen,
                ),
              );
            },
          ),
          if (authState.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.account_circle, color: AppConstants.primaryGold),
              onPressed: () => context.push('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text(
                'Login',
                style: TextStyle(color: AppConstants.primaryGold, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      drawer: _buildMobileDrawer(context, ref, authState),
      bottomNavigationBar: const MobileBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image Auto-Slider with Search Bar Overlay
            Stack(
              children: [
                const HeroCarousel(),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.warmWhite.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppConstants.deepGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) {
                              context.go('/packages');
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search Hajj or Umrah package...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune, color: AppConstants.primaryGold),
                          onPressed: () => context.go('/packages'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Quick Actions 2x2 Grid (Book Hajj, Book Umrah, Air Tickets, Visa Help)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QUICK SERVICES',
                    style: TextStyle(
                      color: AppConstants.primaryGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How Can We Assist You?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _QuickActionTile(
                        icon: Icons.mosque,
                        title: 'Book Hajj 2026',
                        subtitle: 'VIP Tents & Hotels',
                        onTap: () => context.go('/packages?type=hajj'),
                      ),
                      _QuickActionTile(
                        icon: Icons.nightlight_round,
                        title: 'Book Umrah',
                        subtitle: 'Ramzan & Fixed Group',
                        onTap: () => context.go('/packages?type=umrah'),
                      ),
                      _QuickActionTile(
                        icon: Icons.flight,
                        title: 'Air Tickets',
                        subtitle: 'Direct Flights',
                        onTap: () => context.go('/services'),
                      ),
                      _QuickActionTile(
                        icon: Icons.card_travel,
                        title: 'Visa & Forex',
                        subtitle: 'Fast Processing',
                        onTap: () => context.go('/services'),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            // 3. Featured Packages (Horizontal Scroll - Card width 85% screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          color: AppConstants.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Featured Packages',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go('/packages'),
                    child: const Text('View All', style: TextStyle(color: AppConstants.primaryGold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            packagesAsync.when(
              data: (packages) {
                final list = packages.take(5).toList();
                return SizedBox(
                  height: 380,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: PackageCard(
                          package: list[index],
                          width: screenWidth * 0.85,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: AppConstants.primaryGold),
                ),
              ),
              error: (err, stack) => const Text('Could not load packages'),
            ),

            const SizedBox(height: 32),

            // 4. Why Jamal Vertical List
            const WhyChooseUs(),

            const SizedBox(height: 16),

            // 5. Sacred Pilgrimage Photo Gallery
            const GallerySection(),

            const SizedBox(height: 16),

            // 6. YouTube Channel Vlogs & Guidance
            const VideosSection(),

            // 7. Testimonials Swipe Cards
            const TestimonialsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, WidgetRef ref, dynamic authState) {
    return Drawer(
      backgroundColor: AppConstants.softCream,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppConstants.deepGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const AppLogo(size: 32, borderRadius: 8),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          color: AppConstants.warmWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.tagline,
                  style: AppTheme.islamicAccentStyle(fontSize: 12, color: AppConstants.primaryGold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppConstants.deepGreen),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_travel, color: AppConstants.deepGreen),
            title: const Text('Hajj & Umrah Packages'),
            onTap: () {
              Navigator.pop(context);
              context.go('/packages');
            },
          ),
          ListTile(
            leading: const Icon(Icons.room_service, color: AppConstants.deepGreen),
            title: const Text('Services & Visa'),
            onTap: () {
              Navigator.pop(context);
              context.go('/services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.send, color: AppConstants.deepGreen),
            title: const Text('Contact & Inquiry'),
            onTap: () {
              Navigator.pop(context);
              context.go('/enquiry');
            },
          ),
          const Divider(),
          if (authState.isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.person, color: AppConstants.deepGreen),
              title: Text(authState.profile?.fullName ?? 'My Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            if (authState.isAdmin)
              ListTile(
                leading: const Icon(Icons.dashboard, color: AppConstants.primaryGold),
                title: const Text('Admin Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin');
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login, color: AppConstants.primaryGold),
              title: const Text('Login / Register'),
              onTap: () {
                Navigator.pop(context);
                context.push('/login');
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.glassCardDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.deepGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppConstants.primaryGold, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.deepGreen,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppConstants.charcoal.withValues(alpha: 0.6),
                    ),
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
