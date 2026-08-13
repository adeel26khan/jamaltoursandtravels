import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/bookings_provider.dart';

class AdminBookingsManager extends ConsumerStatefulWidget {
  const AdminBookingsManager({super.key});

  @override
  ConsumerState<AdminBookingsManager> createState() => _AdminBookingsManagerState();
}

class _AdminBookingsManagerState extends ConsumerState<AdminBookingsManager> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);
    final bookingNotifier = ref.read(bookingCreateProvider.notifier);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings & Pilgrim Reservations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 4),
          const Text('View and manage pilgrim booking statuses and Razorpay payment confirmations.'),
          const SizedBox(height: 24),

          // Status Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _FilterChip(label: 'All Bookings', isSelected: _filterStatus == 'all', onTap: () => setState(() => _filterStatus = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Paid / Confirmed', isSelected: _filterStatus == 'paid', onTap: () => setState(() => _filterStatus = 'paid')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pending Payment', isSelected: _filterStatus == 'pending', onTap: () => setState(() => _filterStatus = 'pending')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Cancelled', isSelected: _filterStatus == 'cancelled', onTap: () => setState(() => _filterStatus = 'cancelled')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          bookingsAsync.when(
            data: (bookings) {
              final filtered = _filterStatus == 'all'
                  ? bookings
                  : bookings.where((b) => b.paymentStatus == _filterStatus).toList();

              if (filtered.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: AppTheme.glassCardDecoration(),
                  child: const Center(child: Text('No bookings match the selected status filter.')),
                );
              }

              return Container(
                width: double.infinity,
                decoration: AppTheme.glassCardDecoration(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Booking ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Pilgrims', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Departure Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filtered.map((b) {
                      final displayId = b.id.length > 8 ? b.id.substring(0, 8).toUpperCase() : b.id;
                      return DataRow(cells: [
                        DataCell(Text('BK-$displayId', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen))),
                        DataCell(Text('${b.numPilgrims} Person(s)')),
                        DataCell(Text('${b.travelDate.day}/${b.travelDate.month}/${b.travelDate.year}')),
                        DataCell(Text(currencyFormat.format(b.totalAmount))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: b.paymentStatus == 'paid' ? Colors.green : (b.paymentStatus == 'pending' ? Colors.orange : Colors.red),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b.paymentStatus.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              bookingNotifier.updatePaymentStatus(b.id, val);
                              ref.invalidate(userBookingsProvider);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'paid', child: Text('Mark Paid')),
                              PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
                              PopupMenuItem(value: 'cancelled', child: Text('Cancel Booking')),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
            error: (err, stack) => const Text('Could not load bookings'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppConstants.primaryGold,
      backgroundColor: AppConstants.warmWhite,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.charcoal : AppConstants.deepGreen,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
