import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/package_model.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final double? width;

  const PackageCard({
    super.key,
    required this.package,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      width: width,
      decoration: AppTheme.glassCardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Stack
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: package.images.isNotEmpty
                        ? package.images.first
                        : 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppConstants.lightGray),
                    errorWidget: (context, url, err) => Container(
                      color: AppConstants.deepGreen,
                      child: const Icon(Icons.mosque, color: AppConstants.primaryGold, size: 40),
                    ),
                  ),
                ),
                // Gradient Shadow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                // Badge
                if (package.badge != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGold,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        package.badge!.toUpperCase(),
                        style: const TextStyle(
                          color: AppConstants.charcoal,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Package Type Tag
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppConstants.deepGreen.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppConstants.primaryGold, width: 0.8),
                    ),
                    child: Text(
                      '${package.type.toUpperCase()} PACKAGE',
                      style: const TextStyle(
                        color: AppConstants.warmWhite,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Details Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    package.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 6),

                  // Key Inclusions Chips Row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: const [
                      _FeatureChip(icon: Icons.flight_takeoff, label: 'Direct Flight'),
                      _FeatureChip(icon: Icons.star, label: '5★ Haram Hotel'),
                      _FeatureChip(icon: Icons.menu_book, label: 'Scholar Guide'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Duration Breakdown
                  Row(
                    children: [
                      const Icon(Icons.hotel, size: 14, color: AppConstants.deepGreen),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${package.durationDays} Days (${package.makkahNights} Makkah + ${package.madinahNights} Madinah)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppConstants.charcoal.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Seats remaining
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 14, color: AppConstants.primaryGold),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${package.availableSeats} seats left of ${package.maxSeats}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: package.availableSeats < 15 ? Colors.redAccent : AppConstants.deepGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Divider(height: 1, color: AppConstants.borderGold),
                  const SizedBox(height: 10),

                  // Price & CTA Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (package.originalPriceInr != null)
                              Text(
                                currencyFormat.format(package.originalPriceInr),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              currencyFormat.format(package.priceInr),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.deepGreen,
                              ),
                            ),
                            const Text(
                              '+ 5% GST All-Inclusive',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppConstants.primaryGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () => context.push('/packages/${package.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGold,
                          foregroundColor: AppConstants.charcoal,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 1,
                        ),
                        child: const Text(
                          'DETAILS',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
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

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.softCream,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppConstants.borderGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: AppConstants.deepGreen),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppConstants.deepGreen, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
