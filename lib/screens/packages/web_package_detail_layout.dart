import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/package_model.dart';
import '../../models/itinerary_model.dart';
import '../../providers/packages_provider.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/app_footer.dart';

class WebPackageDetailLayout extends ConsumerWidget {
  final PackageModel package;

  const WebPackageDetailLayout({super.key, required this.package});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerariesAsync = ref.watch(packageItinerariesProvider(package.id));
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: const WebNavbar(activeRoute: '/packages'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header & Breadcrumb
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 60),
              color: AppConstants.deepGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home  /  Packages  /  ${package.title}',
                    style: const TextStyle(color: AppConstants.primaryGold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          package.type.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppConstants.charcoal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${package.durationDays} Days (${package.makkahNights} Nights Makkah + ${package.madinahNights} Nights Madinah)',
                        style: TextStyle(color: AppConstants.warmWhite.withValues(alpha: 0.85), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main 2-Column Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content Column (Flex 3)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Gallery Grid
                        _buildImageGallery(context),
                        const SizedBox(height: 32),

                        // Overview Description
                        _buildSectionHeader(context, 'PACKAGE OVERVIEW'),
                        const SizedBox(height: 12),
                        Text(
                          package.description,
                          style: const TextStyle(fontSize: 15, height: 1.6, color: AppConstants.charcoal),
                        ),
                        const SizedBox(height: 32),

                        // Hotel Stay Details (Makkah & Madinah)
                        _buildSectionHeader(context, 'HOTEL ACCOMMODATION'),
                        const SizedBox(height: 16),
                        _buildHotelCards(context),
                        const SizedBox(height: 32),

                        // Day-by-day Itinerary Timeline
                        _buildSectionHeader(context, 'DAY-BY-DAY ITINERARY'),
                        const SizedBox(height: 16),
                        itinerariesAsync.when(
                          data: (itineraries) => _buildItineraryTimeline(context, itineraries),
                          loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
                          error: (err, stack) => const Text('Could not load itinerary schedule.'),
                        ),
                        const SizedBox(height: 32),

                        // Inclusions & Exclusions Checklist
                        _buildSectionHeader(context, 'INCLUSIONS & EXCLUSIONS'),
                        const SizedBox(height: 16),
                        _buildInclusionsExclusions(context),
                        const SizedBox(height: 32),

                        // Price & Tax Breakdown Table
                        _buildSectionHeader(context, 'PRICE & TAX BREAKDOWN'),
                        const SizedBox(height: 16),
                        _buildPriceBreakdownTable(context, currencyFormat),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Right Sticky Booking Sidebar Card (Flex 2)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: AppTheme.glassCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BOOK THIS PACKAGE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price Display
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currencyFormat.format(package.priceInr),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.deepGreen,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '/ pilgrim (+ 5% GST)',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.event_seat, color: AppConstants.primaryGold, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${package.availableSeats} Seats Available',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          _FeatureCheckRow(text: 'Direct Flight Air Tickets'),
                          _FeatureCheckRow(text: 'Umrah Visa & Medical Insurance'),
                          _FeatureCheckRow(text: '5-Star Haram Facing Hotels'),
                          _FeatureCheckRow(text: 'Sehri, Iftar & All Meals'),
                          _FeatureCheckRow(text: 'AC Buses & Scholars Ziyarat Guide'),
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/booking?packageId=${package.id}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryGold,
                                foregroundColor: AppConstants.charcoal,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: const Text(
                                'PROCEED TO BOOKING',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/enquiry?package=${Uri.encodeComponent(package.title)}'),
                              icon: const Icon(Icons.headset_mic, color: AppConstants.deepGreen),
                              label: const Text('CUSTOM ENQUIRY'),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.deepGreen,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 3, width: 40, color: AppConstants.primaryGold),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final images = package.images.isNotEmpty
        ? package.images
        : [
            'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1200&q=80',
            'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1200&q=80',
          ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: CachedNetworkImageProvider(images.first),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(images[1]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHotelCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HotelItemCard(
            city: 'MAKKAH MUKARRAMAH',
            hotelName: 'Swissôtel Makkah / Anjum Hotel',
            stars: 5,
            distance: '100m from Haram Piazza',
            nights: package.makkahNights,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HotelItemCard(
            city: 'MADINAH MUNAWWARAH',
            hotelName: 'Pullman Zamzam Madinah',
            stars: 5,
            distance: '150m from Masjid An-Nabawi',
            nights: package.madinahNights,
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryTimeline(BuildContext context, List<PackageItineraryModel> list) {
    if (list.isEmpty) return const Text('Itinerary details updating soon.');

    return Column(
      children: list.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.glassCardDecoration(),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.deepGreen,
              child: Text(
                'D${item.dayNumber}',
                style: const TextStyle(color: AppConstants.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
            ),
            subtitle: Text('City: ${item.city}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.description,
                    style: const TextStyle(height: 1.5, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInclusionsExclusions(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('INCLUSIONS', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                const SizedBox(height: 12),
                _CheckRow(text: 'Return Direct Air Ticket', isCheck: true),
                _CheckRow(text: 'Umrah Visa & Health Insurance', isCheck: true),
                _CheckRow(text: '5-Star Haram Facing Hotels', isCheck: true),
                _CheckRow(text: 'Daily Buffet Sehri & Iftar Meals', isCheck: true),
                _CheckRow(text: 'Guided Historical Ziyarat in Makkah & Madinah', isCheck: true),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EXCLUSIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const SizedBox(height: 12),
                _CheckRow(text: 'Personal Shopping & Laundry', isCheck: false),
                _CheckRow(text: 'Excess Baggage Fees', isCheck: false),
                _CheckRow(text: 'Room Service & Extra Meals', isCheck: false),
                _CheckRow(text: 'Individual Taxi Charges', isCheck: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdownTable(BuildContext context, NumberFormat format) {
    return Container(
      decoration: AppTheme.glassCardDecoration(),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Particulars', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount (INR)', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          DataRow(cells: [
            const DataCell(Text('Base Package Price')),
            DataCell(Text(format.format(package.priceInr))),
          ]),
          DataRow(cells: [
            DataCell(Text('GST (${package.gstRate}%)')),
            DataCell(Text(format.format(package.gstAmount))),
          ]),
          DataRow(cells: [
            const DataCell(Text('Total Payable Per Pilgrim', style: TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(
              format.format(package.totalPriceWithGst),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen, fontSize: 16),
            )),
          ]),
        ],
      ),
    );
  }
}

class _HotelItemCard extends StatelessWidget {
  final String city;
  final String hotelName;
  final int stars;
  final String distance;
  final int nights;

  const _HotelItemCard({
    required this.city,
    required this.hotelName,
    required this.stars,
    required this.distance,
    required this.nights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(city, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
          const SizedBox(height: 4),
          Text(hotelName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(children: List.generate(stars, (_) => const Icon(Icons.star, color: AppConstants.primaryGold, size: 14))),
              const SizedBox(width: 8),
              Text('$nights Nights Stay', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.directions_walk, size: 14, color: AppConstants.deepGreen),
              const SizedBox(width: 4),
              Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCheckRow extends StatelessWidget {
  final String text;
  const _FeatureCheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppConstants.deepGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  final bool isCheck;

  const _CheckRow({required this.text, required this.isCheck});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isCheck ? Icons.check : Icons.close,
            color: isCheck ? AppConstants.deepGreen : Colors.redAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
