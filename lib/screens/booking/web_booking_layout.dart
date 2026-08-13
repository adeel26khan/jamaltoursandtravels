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
import '../../widgets/web_navbar.dart';
import '../../widgets/app_footer.dart';
import 'booking_confirmation_dialog.dart';

class WebBookingLayout extends ConsumerStatefulWidget {
  final String? packageId;

  const WebBookingLayout({super.key, this.packageId});

  @override
  ConsumerState<WebBookingLayout> createState() => _WebBookingLayoutState();
}

class _WebBookingLayoutState extends ConsumerState<WebBookingLayout> {
  final _formKey = GlobalKey<FormState>();
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
          SnackBar(
            content: Text('Payment Failed: ${response.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  void _addPilgrimController() {
    _pilgrimControllers.add({
      'name': TextEditingController(),
      'passport': TextEditingController(),
      'gender': TextEditingController(text: 'male'),
    });
  }

  void _removePilgrimController(int index) {
    if (_pilgrimControllers.length > 1) {
      _pilgrimControllers[index]['name']?.dispose();
      _pilgrimControllers[index]['passport']?.dispose();
      _pilgrimControllers[index]['gender']?.dispose();
      _pilgrimControllers.removeAt(index);
    }
  }

  @override
  void dispose() {
    for (var p in _pilgrimControllers) {
      p['name']?.dispose();
      p['passport']?.dispose();
      p['gender']?.dispose();
    }
    _razorpayService.dispose();
    super.dispose();
  }

  void _onProceedToPayment() async {
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a package to proceed')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final pilgrimDetails = _pilgrimControllers.map((p) => {
        'full_name': p['name']!.text.trim(),
        'passport_number': p['passport']!.text.trim(),
        'gender': p['gender']!.text.trim(),
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
  }

  void _handlePaymentSuccess(String paymentId) {
    final bookingState = ref.read(bookingCreateProvider);
    final bookingNotifier = ref.read(bookingCreateProvider.notifier);

    if (bookingState.bookingId != null) {
      bookingNotifier.updatePaymentStatus(bookingState.bookingId!, 'paid');
    }

    final pilgrimDetails = _pilgrimControllers.map((p) => {
      'full_name': p['name']!.text.trim(),
      'passport_number': p['passport']!.text.trim(),
      'gender': p['gender']!.text.trim(),
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingConfirmationDialog(
        bookingId: bookingState.bookingId ?? 'BK-9999',
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

    // Auto-select package if packageId parameter was provided
    packagesAsync.whenData((packages) {
      if (_selectedPackage == null) {
        if (widget.packageId != null && widget.packageId!.isNotEmpty) {
          _selectedPackage = packages.firstWhere((p) => p.id == widget.packageId, orElse: () => packages.first);
        } else if (packages.isNotEmpty) {
          _selectedPackage = packages.first;
        }
      }
    });

    final totalPrice = (_selectedPackage?.totalPriceWithGst ?? 0.0) * _numPilgrims;

    return Scaffold(
      appBar: const WebNavbar(activeRoute: '/booking'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 60),
              color: AppConstants.deepGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Home  /  Package Booking Workspace', style: TextStyle(color: AppConstants.primaryGold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'Book Your Sacred Hajj & Umrah Journey',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // 2-Column Booking Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Main Form Column (Flex 3)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Select Package Dropdown
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.glassCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('1. SELECT YOUR PACKAGE', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                                const SizedBox(height: 14),
                                packagesAsync.when(
                                  data: (packages) {
                                    return DropdownButtonFormField<PackageModel>(
                                      isExpanded: true,
                                      initialValue: _selectedPackage,
                                      decoration: const InputDecoration(
                                        labelText: 'Hajj or Umrah Package',
                                        prefixIcon: Icon(Icons.mosque, color: AppConstants.deepGreen),
                                      ),
                                      items: packages
                                          .map((p) => DropdownMenuItem(
                                                value: p,
                                                child: Text('${p.title} (${currencyFormat.format(p.priceInr)} + 5% GST)'),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedPackage = val;
                                        });
                                      },
                                    );
                                  },
                                  loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
                                  error: (err, stack) => const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Travel Date & Pilgrims Counter
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.glassCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('2. TRAVEL DATE & PILGRIM COUNT', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
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
                                          decoration: const InputDecoration(
                                            labelText: 'Departure Travel Date',
                                            prefixIcon: Icon(Icons.calendar_today, color: AppConstants.deepGreen),
                                          ),
                                          child: Text('${_travelDate.day}/${_travelDate.month}/${_travelDate.year}'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Number of Pilgrims',
                                          prefixIcon: Icon(Icons.groups, color: AppConstants.deepGreen),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text('$_numPilgrims Pilgrim(s)', overflow: TextOverflow.ellipsis),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if (_numPilgrims > 1) {
                                                      setState(() {
                                                        _numPilgrims--;
                                                        _removePilgrimController(_numPilgrims);
                                                      });
                                                    }
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                                    child: Icon(Icons.remove_circle_outline, size: 18, color: AppConstants.deepGreen),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _numPilgrims++;
                                                      _addPilgrimController();
                                                    });
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                                    child: Icon(Icons.add_circle_outline, size: 18, color: AppConstants.deepGreen),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Dynamic Pilgrim Details List
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.glassCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('3. PILGRIM INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
                                const SizedBox(height: 16),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _numPilgrims,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Pilgrim #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: TextFormField(
                                                  controller: _pilgrimControllers[index]['name'],
                                                  decoration: const InputDecoration(labelText: 'Full Name (as in Passport) *'),
                                                  validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _pilgrimControllers[index]['passport'],
                                                  decoration: const InputDecoration(labelText: 'Passport Number'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Right Sticky Summary & Razorpay Payment Card (Flex 2)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: AppTheme.glassCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PAYMENT SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGold, letterSpacing: 1)),
                            const SizedBox(height: 16),

                            if (_selectedPackage != null) ...[
                              Text(_selectedPackage!.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.deepGreen)),
                              const SizedBox(height: 8),
                              _SummaryRow('Base Price per Pilgrim:', currencyFormat.format(_selectedPackage!.priceInr)),
                              _SummaryRow('GST (5%) per Pilgrim:', currencyFormat.format(_selectedPackage!.gstAmount)),
                              _SummaryRow('Rate Incl. Tax:', currencyFormat.format(_selectedPackage!.totalPriceWithGst)),
                              _SummaryRow('Number of Pilgrims:', 'x $_numPilgrims'),
                              const Divider(),
                              _SummaryRow('TOTAL AMOUNT PAYABLE:', currencyFormat.format(totalPrice), isTotal: true),
                            ],
                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _onProceedToPayment,
                                icon: const Icon(Icons.payment, color: AppConstants.charcoal),
                                label: const Text('PAY SECURELY VIA RAZORPAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryGold,
                                  foregroundColor: AppConstants.charcoal,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.security, size: 16, color: Colors.green),
                                SizedBox(width: 6),
                                Text('256-Bit SSL Encrypted & Razorpay Secured', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 14 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppConstants.deepGreen : null,
            ),
          ),
        ],
      ),
    );
  }
}
