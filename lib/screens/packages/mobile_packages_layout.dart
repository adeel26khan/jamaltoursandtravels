import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/package_model.dart';
import '../../providers/packages_filter_provider.dart';
import '../../widgets/mobile_bottom_nav.dart';

class MobilePackagesLayout extends ConsumerWidget {
  final String? initialType;

  const MobilePackagesLayout({super.key, this.initialType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(packageFilterProvider);
    final filterNotifier = ref.read(packageFilterProvider.notifier);
    final filteredPackages = ref.watch(filteredPackagesProvider);

    return DefaultTabController(
      length: 4,
      initialIndex: _getTabIndex(filterState.packageType ?? initialType),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppConstants.deepGreen,
          title: const Text('Hajj & Umrah Packages'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppConstants.primaryGold),
              onPressed: () => _showFilterBottomSheet(context, ref),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppConstants.primaryGold,
            labelColor: AppConstants.primaryGold,
            unselectedLabelColor: AppConstants.warmWhite.withValues(alpha: 0.7),
            onTap: (index) {
              switch (index) {
                case 0:
                  filterNotifier.setPackageType('all');
                  break;
                case 1:
                  filterNotifier.setPackageType('hajj');
                  break;
                case 2:
                  filterNotifier.setPackageType('umrah');
                  break;
                case 3:
                  filterNotifier.setPackageType('air_ticket');
                  break;
              }
            },
            tabs: const [
              Tab(text: 'All Packages'),
              Tab(text: 'Hajj 2026'),
              Tab(text: 'Umrah Packages'),
              Tab(text: 'Air Tickets'),
            ],
          ),
        ),
        bottomNavigationBar: const MobileBottomNav(currentIndex: 1),
        body: filteredPackages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No packages match your search filters.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => filterNotifier.resetFilters(),
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPackages.length,
                itemBuilder: (context, index) {
                  final pkg = filteredPackages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MobilePackageCard(package: pkg),
                  );
                },
              ),
      ),
    );
  }

  int _getTabIndex(String? type) {
    if (type == 'hajj') return 1;
    if (type == 'umrah') return 2;
    if (type == 'air_ticket') return 3;
    return 0;
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.softCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final filterState = ref.watch(packageFilterProvider);
            final filterNotifier = ref.read(packageFilterProvider.notifier);
            final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Packages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          filterNotifier.resetFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Price Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        currencyFormat.format(filterState.maxPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                      ),
                    ],
                  ),
                  Slider(
                    value: filterState.maxPrice,
                    min: 50000,
                    max: 700000,
                    divisions: 13,
                    activeColor: AppConstants.primaryGold,
                    onChanged: (val) => filterNotifier.setMaxPrice(val),
                  ),
                  const SizedBox(height: 16),

                  // Sort Option
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: filterState.sortBy,
                    items: const [
                      DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                      DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                      DropdownMenuItem(value: 'duration_desc', child: Text('Duration: Longest First')),
                    ],
                    onChanged: (val) {
                      if (val != null) filterNotifier.setSortBy(val);
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGold,
                        foregroundColor: AppConstants.charcoal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MobilePackageCard extends StatelessWidget {
  final PackageModel package;

  const _MobilePackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      decoration: AppTheme.glassCardDecoration(),
      child: InkWell(
        onTap: () => context.push('/packages/${package.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.deepGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${package.durationDays} Days (${package.makkahNights} Makkah + ${package.madinahNights} Madinah)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.charcoal.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (package.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        package.badge!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.charcoal,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Specs Row (Flight | Hotel | Food | Guide)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SpecItem(icon: Icons.flight, label: 'Flight'),
                  _SpecItem(icon: Icons.hotel, label: '5★ Hotel'),
                  _SpecItem(icon: Icons.restaurant, label: 'Sehri/Iftar'),
                  _SpecItem(icon: Icons.record_voice_over, label: 'Scholar Guide'),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Price & CTA Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (package.originalPriceInr != null)
                        Text(
                          currencyFormat.format(package.originalPriceInr),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        currencyFormat.format(package.priceInr),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                        ),
                      ),
                      const Text(
                        '+ 5% GST',
                        style: TextStyle(fontSize: 10, color: AppConstants.primaryGold),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/packages/${package.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGold,
                      foregroundColor: AppConstants.charcoal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('DETAILS & BOOK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppConstants.deepGreen),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppConstants.charcoal.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
