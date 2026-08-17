import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/package_model.dart';
import '../../providers/packages_provider.dart';

class MobilePackageDetailLayout extends ConsumerStatefulWidget {
  final PackageModel package;

  const MobilePackageDetailLayout({super.key, required this.package});

  @override
  ConsumerState<MobilePackageDetailLayout> createState() => _MobilePackageDetailLayoutState();
}

class _MobilePackageDetailLayoutState extends ConsumerState<MobilePackageDetailLayout> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final itinerariesAsync = ref.watch(packageItinerariesProvider(widget.package.id));
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final images = widget.package.images.isNotEmpty
        ? widget.package.images
        : [
            'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80',
          ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header App Bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppConstants.deepGreen,
            leading: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _activeImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_activeImageIndex + 1} / ${images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.package.type.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppConstants.charcoal),
                        ),
                      ),
                      if (widget.package.badge != null)
                        Text(
                          widget.package.badge!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.package.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    '${widget.package.durationDays} Days (${widget.package.makkahNights} Makkah + ${widget.package.madinahNights} Madinah)',
                    style: TextStyle(color: AppConstants.charcoal.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Overview
                  const Text('PACKAGE OVERVIEW', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                  const SizedBox(height: 6),
                  Text(
                    widget.package.description,
                    style: const TextStyle(height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Hotels
                  const Text('HOTEL STAY', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                  const SizedBox(height: 10),
                  _MobileHotelCard(
                    city: 'Makkah Mukarramah',
                    name: 'Swissôtel / Anjum Makkah (5★)',
                    distance: '100m from Haram',
                    nights: widget.package.makkahNights,
                  ),
                  const SizedBox(height: 10),
                  _MobileHotelCard(
                    city: 'Madinah Munawwarah',
                    name: 'Pullman Zamzam Madinah (5★)',
                    distance: '150m from Prophet\'s Mosque',
                    nights: widget.package.madinahNights,
                  ),
                  const SizedBox(height: 24),

                  // Day-by-Day Itinerary Timeline
                  const Text('DAY-BY-DAY SCHEDULE', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                  const SizedBox(height: 10),
                  itinerariesAsync.when(
                    data: (list) {
                      if (list.isEmpty) return const Text('Schedule update in progress.');
                      return Column(
                        children: list.map((item) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppConstants.deepGreen,
                                child: Text('D${item.dayNumber}', style: const TextStyle(color: AppConstants.primaryGold, fontSize: 10)),
                              ),
                              title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(item.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
                    error: (err, stack) => const Text('Could not load schedule'),
                  ),
                  const SizedBox(height: 24),

                  // Price Breakdown
                  const Text('PRICE BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.glassCardDecoration(),
                    child: Column(
                      children: [
                        _RowPrice('Base Package Price', currencyFormat.format(widget.package.priceInr)),
                        const SizedBox(height: 6),
                        _RowPrice('GST (5%)', currencyFormat.format(widget.package.gstAmount)),
                        const Divider(),
                        _RowPrice('Total Payable Per Pilgrim', currencyFormat.format(widget.package.totalPriceWithGst), isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Padding for sticky bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Sticky Bottom Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.deepGreen,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currencyFormat.format(widget.package.priceInr),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryGold,
                  ),
                ),
                const Text('+ 5% GST', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            ElevatedButton(
              onPressed: () => context.push('/booking?packageId=${widget.package.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGold,
                foregroundColor: AppConstants.charcoal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('BOOK NOW', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHotelCard extends StatelessWidget {
  final String city;
  final String name;
  final String distance;
  final int nights;

  const _MobileHotelCard({
    required this.city,
    required this.name,
    required this.distance,
    required this.nights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassCardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.hotel, color: AppConstants.primaryGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                Text('$distance • $nights Nights', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowPrice extends StatelessWidget {
  final String title;
  final String amount;
  final bool isBold;

  const _RowPrice(this.title, this.amount, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        Text(amount, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 15 : 13, color: isBold ? AppConstants.deepGreen : null)),
      ],
    );
  }
}
