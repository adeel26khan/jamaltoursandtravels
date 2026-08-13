import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/packages_filter_provider.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/package_card.dart';
import '../../widgets/app_footer.dart';

class WebPackagesLayout extends ConsumerWidget {
  const WebPackagesLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(packageFilterProvider);
    final filterNotifier = ref.read(packageFilterProvider.notifier);
    final filteredPackages = ref.watch(filteredPackagesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: const WebNavbar(activeRoute: '/packages'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
              decoration: BoxDecoration(
                color: AppConstants.deepGreen,
                gradient: LinearGradient(
                  colors: [
                    AppConstants.deepGreen,
                    AppConstants.deepGreen.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home  /  Hajj & Umrah Packages',
                    style: TextStyle(color: AppConstants.primaryGold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore Sacred Pilgrimage Packages',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transparent all-inclusive packages with 5-Star Haram facing hotels & scholar guidance.',
                    style: TextStyle(
                      color: AppConstants.warmWhite.withValues(alpha: 0.85),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Content Area (Sidebar Filters + Package Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Filter Sidebar (Width 280)
                  SizedBox(
                    width: 280,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'FILTERS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.deepGreen,
                                  letterSpacing: 1,
                                ),
                              ),
                              TextButton(
                                onPressed: () => filterNotifier.resetFilters(),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppConstants.borderGold),
                          const SizedBox(height: 12),

                          // Package Type Filter Options
                          const Text(
                            'Package Category',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          _FilterCategoryTile(
                            title: 'All Packages',
                            value: null,
                            selectedValue: filterState.packageType,
                            onChanged: (val) => filterNotifier.setPackageType(val),
                          ),
                          _FilterCategoryTile(
                            title: 'Umrah Packages',
                            value: 'umrah',
                            selectedValue: filterState.packageType,
                            onChanged: (val) => filterNotifier.setPackageType(val),
                          ),
                          _FilterCategoryTile(
                            title: 'Hajj Packages',
                            value: 'hajj',
                            selectedValue: filterState.packageType,
                            onChanged: (val) => filterNotifier.setPackageType(val),
                          ),
                          _FilterCategoryTile(
                            title: 'Air Tickets',
                            value: 'air_ticket',
                            selectedValue: filterState.packageType,
                            onChanged: (val) => filterNotifier.setPackageType(val),
                          ),
                          const SizedBox(height: 20),

                          // Max Price Filter Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Max Budget',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                currencyFormat.format(filterState.maxPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.deepGreen,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: filterState.maxPrice,
                            min: 50000,
                            max: 700000,
                            divisions: 13,
                            activeColor: AppConstants.primaryGold,
                            inactiveColor: AppConstants.borderGold,
                            onChanged: (val) => filterNotifier.setMaxPrice(val),
                          ),
                          const SizedBox(height: 16),

                          // Duration Filter Chips
                          const Text(
                            'Max Duration',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ChoiceChipItem(
                                label: 'Any',
                                isSelected: filterState.maxDurationDays == null,
                                onSelected: () => filterNotifier.setMaxDuration(null),
                              ),
                              _ChoiceChipItem(
                                label: '≤ 15 Days',
                                isSelected: filterState.maxDurationDays == 15,
                                onSelected: () => filterNotifier.setMaxDuration(15),
                              ),
                              _ChoiceChipItem(
                                label: '≤ 20 Days',
                                isSelected: filterState.maxDurationDays == 20,
                                onSelected: () => filterNotifier.setMaxDuration(20),
                              ),
                              _ChoiceChipItem(
                                label: '≤ 30 Days',
                                isSelected: filterState.maxDurationDays == 30,
                                onSelected: () => filterNotifier.setMaxDuration(30),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Right Packages Main Content Grid
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Control Header Bar (Count + Sort)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${filteredPackages.length} Packages',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.deepGreen,
                              ),
                            ),
                            Row(
                              children: [
                                const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.warmWhite,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppConstants.borderGold),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: filterState.sortBy,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'price_asc', child: Text('Price: Low to High')),
                                        DropdownMenuItem(
                                            value: 'price_desc', child: Text('Price: High to Low')),
                                        DropdownMenuItem(
                                            value: 'duration_desc', child: Text('Duration: Longest First')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) filterNotifier.setSortBy(val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Packages 3-Column Grid
                        if (filteredPackages.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(60),
                            alignment: Alignment.center,
                            child: const Column(
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  'No packages match your selected filters.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final is3Col = width > 980;
                              final is2Col = width > 620 && width <= 980;
                              final spacing = 20.0;
                              final cardWidth = is3Col
                                  ? (width - (spacing * 2)) / 3
                                  : (is2Col ? (width - spacing) / 2 : width);

                              return Wrap(
                                spacing: spacing,
                                runSpacing: 24,
                                children: filteredPackages.map((pkg) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: PackageCard(package: pkg),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                      ],
                    ),
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
}

class _FilterCategoryTile extends StatelessWidget {
  final String title;
  final String? value;
  final String? selectedValue;
  final Function(String?) onChanged;

  const _FilterCategoryTile({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: isSelected ? AppConstants.primaryGold : AppConstants.borderGold,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppConstants.deepGreen : AppConstants.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ChoiceChipItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppConstants.primaryGold,
      backgroundColor: AppConstants.warmWhite,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.charcoal : AppConstants.deepGreen,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppConstants.borderGold),
      ),
    );
  }
}
