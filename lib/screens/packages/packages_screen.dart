import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';
import 'web_packages_layout.dart';
import 'mobile_packages_layout.dart';

class PackagesScreen extends StatelessWidget {
  final String? packageTypeFilter;

  const PackagesScreen({super.key, this.packageTypeFilter});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isWebDesktop(context)
        ? const WebPackagesLayout()
        : MobilePackagesLayout(initialType: packageTypeFilter);
  }
}
