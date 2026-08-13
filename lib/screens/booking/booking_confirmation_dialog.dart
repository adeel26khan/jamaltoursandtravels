import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final String bookingId;
  final String packageName;
  final DateTime travelDate;
  final List<Map<String, String>> pilgrims;
  final double totalAmount;
  final String paymentId;

  const BookingConfirmationDialog({
    super.key,
    required this.bookingId,
    required this.packageName,
    required this.travelDate,
    required this.pilgrims,
    required this.totalAmount,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Dialog(
      backgroundColor: AppConstants.softCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Style Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.deepGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.mosque, color: AppConstants.deepGreen, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(
                              color: AppConstants.warmWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'OFFICIAL BOOKING RECEIPT & CONFIRMATION',
                            style: AppTheme.islamicAccentStyle(fontSize: 10, color: AppConstants.primaryGold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Booking Details Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BOOKING REFERENCE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text(bookingId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('PAYMENT STATUS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('CONFIRMED / PAID', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              _receiptRow('Selected Package:', packageName),
              _receiptRow('Travel Date:', '${travelDate.day}/${travelDate.month}/${travelDate.year}'),
              _receiptRow('Razorpay Payment ID:', paymentId),
              _receiptRow('Total Amount (incl. 5% GST):', currencyFormat.format(totalAmount), isBold: true),
              const SizedBox(height: 16),

              // Pilgrim List
              const Text('REGISTERED PILGRIMS', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppConstants.borderGold),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pilgrims.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = pilgrims[index];
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              '${p['full_name']} (${p['gender'] ?? "Male"}, Passport: ${p['passport_number'] ?? "N/A"})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Address Footer
              Text(
                'Head Office: ${AppConstants.address}\nGSTIN: ${AppConstants.gstNumber}',
                style: TextStyle(fontSize: 10, color: AppConstants.charcoal.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading PDF Booking Receipt...'),
                            backgroundColor: AppConstants.deepGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('DOWNLOAD PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/my-bookings');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGold,
                        foregroundColor: AppConstants.charcoal,
                      ),
                      child: const Text('MY BOOKINGS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppConstants.deepGreen : AppConstants.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
