import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/packages_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/enquiries_provider.dart';

class AdminDashboardOverview extends ConsumerWidget {
  const AdminDashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider);
    final bookingsAsync = ref.watch(userBookingsProvider);
    final enquiryState = ref.watch(enquiryProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 6),
          const Text('Real-time Hajj & Umrah bookings, revenue analytics, and package seat availability.'),
          const SizedBox(height: 28),

          // 4 Metric Stat Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final bookingsList = bookingsAsync.value ?? [];
              final packagesList = packagesAsync.value ?? [];

              final totalRevenue = bookingsList.fold(0.0, (sum, b) => sum + b.totalAmount);
              final totalSeats = packagesList.fold(0, (sum, p) => sum + p.availableSeats);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 1.4 : 1.3,
                children: [
                  _StatCard(
                    title: 'TOTAL BOOKINGS',
                    value: '${bookingsList.length}',
                    subtitle: 'Confirmed Pilgrim Registrations',
                    icon: Icons.book_online,
                    color: Colors.blue.shade700,
                  ),
                  _StatCard(
                    title: 'PENDING ENQUIRIES',
                    value: '${enquiryState.enquiries.where((e) => e.status == 'new').length}',
                    subtitle: 'Uncontacted Lead Inquiries',
                    icon: Icons.mark_chat_unread,
                    color: Colors.orange.shade800,
                  ),
                  _StatCard(
                    title: 'TOTAL REVENUE',
                    value: currencyFormat.format(totalRevenue),
                    subtitle: 'Gross Package Receipts',
                    icon: Icons.account_balance_wallet,
                    color: AppConstants.deepGreen,
                  ),
                  _StatCard(
                    title: 'AVAILABLE SEATS',
                    value: '$totalSeats',
                    subtitle: 'Active Package Openings',
                    icon: Icons.event_seat,
                    color: AppConstants.primaryGold,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 36),

          // Recent Activity Section
          const Text(
            'RECENT BOOKING ACTIVITY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.deepGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          bookingsAsync.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.glassCardDecoration(),
                  child: const Center(child: Text('No recent bookings recorded.')),
                );
              }

              return Container(
                decoration: AppTheme.glassCardDecoration(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Booking ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Pilgrims', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Travel Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Payment Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: bookings.take(5).map((b) {
                      final displayId = b.id.length > 8 ? b.id.substring(0, 8).toUpperCase() : b.id;
                      return DataRow(cells: [
                        DataCell(Text('BK-$displayId', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${b.numPilgrims} Person(s)')),
                        DataCell(Text('${b.travelDate.day}/${b.travelDate.month}/${b.travelDate.year}')),
                        DataCell(Text(currencyFormat.format(b.totalAmount))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: b.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b.paymentStatus.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
            error: (err, stack) => const Text('Could not load activity feed'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppConstants.deepGreen,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
