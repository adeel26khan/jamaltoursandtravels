import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/packages/packages_screen.dart';
import '../screens/packages/package_detail_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/my_bookings_screen.dart';
import '../screens/enquiry/enquiry_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

Page<dynamic> _buildPageWithTransition(BuildContext context, GoRouterState state, Widget child) {
  if (kIsWeb) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const HomeScreen()),
    ),
    GoRoute(
      path: '/packages',
      name: 'packages',
      pageBuilder: (context, state) {
        final type = state.uri.queryParameters['type'];
        return _buildPageWithTransition(context, state, PackagesScreen(packageTypeFilter: type));
      },
    ),
    GoRoute(
      path: '/packages/:id',
      name: 'packageDetail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return _buildPageWithTransition(context, state, PackageDetailScreen(packageId: id));
      },
    ),
    GoRoute(
      path: '/booking',
      name: 'booking',
      pageBuilder: (context, state) {
        final packageId = state.uri.queryParameters['packageId'] ?? '';
        return _buildPageWithTransition(context, state, BookingScreen(packageId: packageId));
      },
    ),
    GoRoute(
      path: '/my-bookings',
      name: 'myBookings',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MyBookingsScreen()),
    ),
    GoRoute(
      path: '/enquiry',
      name: 'enquiry',
      pageBuilder: (context, state) {
        final service = state.uri.queryParameters['service'] ?? state.uri.queryParameters['package'];
        return _buildPageWithTransition(context, state, EnquiryScreen(initialService: service));
      },
    ),
    GoRoute(
      path: '/services',
      name: 'services',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ServicesScreen()),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AboutScreen()),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ContactScreen()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const LoginScreen()),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildPageWithTransition(
          context,
          state,
          OtpScreen(fullName: extra?['fullName'] as String?),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ProfileScreen()),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AdminDashboardScreen()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);
