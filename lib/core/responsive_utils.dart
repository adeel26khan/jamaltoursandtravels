import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'constants.dart';

enum ScreenType { mobile, tablet, desktop }

class ResponsiveUtils {
  static ScreenType getScreenType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= AppConstants.desktopBreakpoint) {
      return ScreenType.desktop;
    } else if (width >= AppConstants.mobileBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop;

  /// CRITICAL RULE — SMART ADAPTIVE UI:
  /// When kIsWeb && screenWidth > 1024: render a premium travel WEBSITE layout (sticky top nav, multi-column grids, hover effects, rich footer).
  /// When !kIsWeb || screenWidth < 600: render a native MOBILE APP layout (bottom nav, swipe gestures, full-screen sheets, FAB).
  static bool isWebDesktop(BuildContext context) {
    return kIsWeb && MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  static bool isNativeMobile(BuildContext context) {
    return !kIsWeb || MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
