import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import 'admin_sidebar.dart';
import 'admin_dashboard_overview.dart';
import 'admin_packages_manager.dart';
import 'admin_bookings_manager.dart';
import 'admin_enquiries_manager.dart';
import 'admin_testimonials_manager.dart';
import 'admin_videos_manager.dart';
import 'admin_hotels_manager.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDesktop = ResponsiveUtils.isWebDesktop(context);

    // Role protection check: Must be logged in and role == 'admin'
    final isAdmin = authState.profile?.role == 'admin';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppConstants.deepGreen,
          title: const Text('Admin Dashboard'),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            decoration: AppTheme.glassCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.deepGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You must be signed in with Admin credentials to access the management dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.phone_android, color: AppConstants.charcoal),
                    label: const Text('ADMIN LOGIN WITH PHONE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGold,
                      foregroundColor: AppConstants.charcoal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return to Home Page'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Body content by tab
    Widget mainContent;
    switch (_selectedTabIndex) {
      case 0:
        mainContent = const AdminDashboardOverview();
        break;
      case 1:
        mainContent = const AdminPackagesManager();
        break;
      case 2:
        mainContent = const AdminBookingsManager();
        break;
      case 3:
        mainContent = const AdminEnquiriesManager();
        break;
      case 4:
        mainContent = const AdminHotelsManager();
        break;
      case 5:
        mainContent = const AdminTestimonialsManager();
        break;
      case 6:
        mainContent = const AdminVideosManager();
        break;
      default:
        mainContent = const AdminDashboardOverview();
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedTabIndex,
              onSelectTab: (index) => setState(() => _selectedTabIndex = index),
            ),
            Expanded(
              child: Container(
                color: AppConstants.softCream,
                child: mainContent,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Admin View
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.deepGreen,
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppConstants.primaryGold),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex.clamp(0, 6),
        selectedItemColor: AppConstants.primaryGold,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppConstants.deepGreen,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard, size: 20), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.mosque, size: 20), label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online, size: 20), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer, size: 20), label: 'Enquiries'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel, size: 20), label: 'Hotels'),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review, size: 20), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library, size: 20), label: 'Videos'),
        ],
      ),
      body: mainContent,
    );
  }
}
