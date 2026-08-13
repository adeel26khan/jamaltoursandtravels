import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive_utils.dart';
import '../../core/constants.dart';
import '../../providers/packages_provider.dart';
import 'web_package_detail_layout.dart';
import 'mobile_package_detail_layout.dart';

class PackageDetailScreen extends ConsumerWidget {
  final String packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(packageDetailProvider(packageId));

    return Scaffold(
      body: packageAsync.when(
        data: (package) {
          if (package == null) {
            return const Scaffold(
              body: Center(
                child: Text('Package not found'),
              ),
            );
          }

          return ResponsiveUtils.isWebDesktop(context)
              ? WebPackageDetailLayout(package: package)
              : MobilePackageDetailLayout(package: package);
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppConstants.primaryGold),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error loading package detail: $err'),
          ),
        ),
      ),
    );
  }
}
