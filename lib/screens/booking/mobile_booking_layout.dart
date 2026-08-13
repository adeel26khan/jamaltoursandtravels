import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/package_model.dart';
import '../../providers/packages_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/razorpay_service.dart';
import 'booking_confirmation_dialog.dart';

class MobileBookingLayout extends ConsumerStatefulWidget {
  final String? packageId;

  const MobileBookingLayout({super.key, this.packageId});

  @override
  ConsumerState<MobileBookingLayout> createState() => _MobileBookingLayoutState();
}

class _MobileBookingLayoutState extends ConsumerState<MobileBookingLayout> {
  int _currentStep = 0;
  final RazorpayService _razorpayService = RazorpayService();

  PackageModel? _selectedPackage;
  DateTime _travelDate = DateTime.now().add(const Duration(days: 30));
  int _numPilgrims = 1;

  final List<Map<String, TextEditingController>> _pilgrimControllers = [];

  @override
  void initState() {
    super.initState();
    _addPilgrimController();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpayService.init(
      onSuccess: (response) => _handlePaymentSuccess(response.paymentId ?? 'pay_success'),
      onFailure: (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Error: ${response.message}'), backgroundColor: Colors.redAccent),
        );
      },
    );
  }

  void _addPilgrimController() {
    _pilgrimControllers.add({
      'name': TextEditingController(),
      'passport': TextEditingController(),
    });
  }

  void _removePilgrimController() {
    if (_pilgrimControllers.length > 1) {
      _pilgrimControllers.last['name']?.dispose();
      _pilgrimControllers.last['passport']?.dispose();
      _pilgrimControllers.removeLast();
    }
  }

  @override
  void dispose() {
    for (var p in _pilgrimControllers) {
      p['name']?.dispose();
      p['passport']?.dispose();
    }
    _razorpayService.dispose();
    super.dispose();
  }

  void _onProceedToPayment() async {
    if (_selectedPackage == null) return;

    final pilgrimDetails = _pilgrimControllers.map((p) => {
      'full_name': p['name']!.text.trim().isNotEmpty ? p['name']!.text.trim() : 'Pilgrim',
      'passport_number': p['passport']!.text.trim(),
    }).toList();

    final bookingNotifier = ref.read(bookingCreateProvider.notifier);
    final bookingId = await bookingNotifier.createBooking(
      packageId: _selectedPackage!.id,
      travelDate: _travelDate,
      numPilgrims: _numPilgrims,
      totalAmount: _selectedPackage!.totalPriceWithGst * _numPilgrims,
      pilgrimDetails: pilgrimDetails,
    );

    if (bookingId != null) {
      final authState = ref.read(authProvider);
      _razorpayService.openCheckout(
        amountInr: _selectedPackage!.totalPriceWithGst * _numPilgrims,
        bookingId: bookingId,
        packageName: _selectedPackage!.title,
        userPhone: authState.profile?.phone ?? '9876543210',
        userEmail: authState.profile?.email ?? 'info@jamalhajumrahtoursntravels.com',
      );
    }
  }

  void _handlePaymentSuccess(String paymentId) {
    final bookingState = ref.read(bookingCreateProvider);

    final pilgrimDetails = _pilgrimControllers.map((p) => {
      'full_name': p['name']!.text.trim().isNotEmpty ? p['name']!.text.trim() : 'Pilgrim',
      'passport_number': p['passport']!.text.trim(),
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingConfirmationDialog(
        bookingId: bookingState.bookingId ?? 'BK-MOBILE',
        packageName: _selectedPackage?.title ?? 'Umrah Package',
        travelDate: _travelDate,
        pilgrims: pilgrimDetails,
        totalAmount: (_selectedPackage?.totalPriceWithGst ?? 125000) * _numPilgrims,
        paymentId: paymentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(packagesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    packagesAsync.whenData((packages) {
      if (_selectedPackage == null && packages.isNotEmpty) {
        _selectedPackage = widget.packageId != null
            ? packages.firstWhere((p) => p.id == widget.packageId, orElse: () => packages.first)
            : packages.first;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.deepGreen,
        title: const Text('Quick Booking Wizard'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _onProceedToPayment();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGold,
                      foregroundColor: AppConstants.charcoal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'PAY VIA RAZORPAY' : 'CONTINUE',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Select Package
          Step(
            title: const Text('Package'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Your Package:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                packagesAsync.when(
                  data: (packages) {
                    return Column(
                      children: packages.map((p) {
                        final isSelected = _selectedPackage?.id == p.id;
                        return Card(
                          color: isSelected ? AppConstants.primaryGold.withValues(alpha: 0.2) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isSelected ? AppConstants.deepGreen : Colors.grey.shade300, width: isSelected ? 2 : 1),
                          ),
                          child: ListTile(
                            onTap: () => setState(() => _selectedPackage = p),
                            title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('${p.durationDays} Days • ${currencyFormat.format(p.priceInr)} + 5% GST'),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppConstants.deepGreen) : null,
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
                  error: (err, stack) => const Text('Error loading packages'),
                ),
              ],
            ),
          ),

          // Step 2: Enter Pilgrim Details & Date
          Step(
            title: const Text('Details'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel Date & Pilgrim Count:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _travelDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _travelDate = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Departure Date', prefixIcon: Icon(Icons.calendar_today)),
                    child: Text('${_travelDate.day}/${_travelDate.month}/${_travelDate.year}'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilgrims: $_numPilgrims Person(s)'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (_numPilgrims > 1) {
                              setState(() {
                                _numPilgrims--;
                                _removePilgrimController();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              _numPilgrims++;
                              _addPilgrimController();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _numPilgrims,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _pilgrimControllers[index]['name'],
                        decoration: InputDecoration(labelText: 'Pilgrim #${index + 1} Full Name'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Step 3: Review & Pay
          Step(
            title: const Text('Summary'),
            isActive: _currentStep >= 2,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BOOKING SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                  const SizedBox(height: 10),
                  Text(_selectedPackage?.title ?? 'Package', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Departure: ${_travelDate.day}/${_travelDate.month}/${_travelDate.year}'),
                  Text('Pilgrims: $_numPilgrims Person(s)'),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PAYABLE:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        currencyFormat.format((_selectedPackage?.totalPriceWithGst ?? 0) * _numPilgrims),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppConstants.deepGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
