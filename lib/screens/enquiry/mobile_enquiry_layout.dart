import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/enquiries_provider.dart';
import '../../providers/packages_provider.dart';
import '../../widgets/mobile_bottom_nav.dart';

class MobileEnquiryLayout extends ConsumerStatefulWidget {
  final String? initialService;
  const MobileEnquiryLayout({super.key, this.initialService});

  @override
  ConsumerState<MobileEnquiryLayout> createState() => _MobileEnquiryLayoutState();
}

class _MobileEnquiryLayoutState extends ConsumerState<MobileEnquiryLayout> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedPackageInterest;
  DateTime? _preferredDate;
  int _numPilgrims = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null && widget.initialService!.isNotEmpty) {
      _selectedPackageInterest = widget.initialService;
      _messageController.text = 'I would like to inquire about ${widget.initialService}. Please provide details & pricing.';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _launchWhatsApp(String name, String pkg) async {
    final message = Uri.encodeComponent("Assalamu Alaikum! I am $name. I want to enquire about $pkg.");
    final url = Uri.parse("https://wa.me/918929175340?text=$message");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _onSubmitEnquiry() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(enquiryProvider.notifier);

      final success = await notifier.submitEnquiry(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        packageInterest: _selectedPackageInterest ?? 'Ramzan Umrah Package',
        preferredDate: _preferredDate,
        numPilgrims: _numPilgrims,
        message: _messageController.text.trim().isNotEmpty ? _messageController.text.trim() : null,
      );

      if (success && mounted) {
        final userName = _nameController.text.trim();
        final userPkg = _selectedPackageInterest ?? 'Umrah Package';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppConstants.softCream,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: AppConstants.deepGreen, size: 48),
                SizedBox(height: 12),
                Text(
                  'Enquiry Submitted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                ),
              ],
            ),
            content: Text(
              'JazakAllah Khair $userName! Our travel team will contact you shortly.\n\nOr click below for instant WhatsApp assistance.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchWhatsApp(userName, userPkg);
                },
                icon: const Icon(Icons.chat, color: AppConstants.charcoal),
                label: const Text('WHATSAPP CHAT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: AppConstants.charcoal,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _formKey.currentState!.reset();
                  _nameController.clear();
                  _phoneController.clear();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enquiryState = ref.watch(enquiryProvider);
    final packagesAsync = ref.watch(packagesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.deepGreen,
        title: const Text('Contact & Package Inquiry'),
      ),
      bottomNavigationBar: const MobileBottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Head Office Contact Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.mosque, color: AppConstants.deepGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppConstants.appName,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('📍 Address:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
                  Text(AppConstants.address, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text('📞 Phone / WhatsApp:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
                  Text('${AppConstants.phone} | ${AppConstants.whatsapp}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text('✉️ Email:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
                  Text(AppConstants.email, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text('🕐 Working Hours:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
                  Text(AppConstants.workingHours, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Inquiry Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEND US A MESSAGE',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number (+91) *',
                        counterText: '',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Phone required';
                        if (val.trim().replaceAll(RegExp(r'\D'), '').length != 10) return '10-digit number required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address (Optional)', prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 14),

                    packagesAsync.when(
                      data: (packages) {
                        final options = <String>{};
                        if (_selectedPackageInterest != null && _selectedPackageInterest!.isNotEmpty) {
                          options.add(_selectedPackageInterest!);
                        }
                        for (final s in AppConstants.services) {
                          if (s['title'] != null) options.add(s['title']!);
                        }
                        for (final p in packages) {
                          options.add(p.title);
                        }

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedPackageInterest,
                          decoration: const InputDecoration(labelText: 'Package or Service Interest', prefixIcon: Icon(Icons.mosque)),
                          items: options
                              .map((title) => DropdownMenuItem(value: title, child: Text(title, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedPackageInterest = val),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (err, stack) => const SizedBox(),
                    ),
                    const SizedBox(height: 14),

                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _preferredDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Preferred Travel Date', prefixIcon: Icon(Icons.calendar_today)),
                        child: Text(
                          _preferredDate != null ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}' : 'Select Travel Date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Number of Pilgrims', prefixIcon: Icon(Icons.groups)),
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
                                    setState(() => _numPilgrims--);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.remove_circle_outline, size: 18, color: AppConstants.deepGreen),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _numPilgrims++),
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
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Special Requests / Message', alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: enquiryState.isSubmitting ? null : _onSubmitEnquiry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGold,
                          foregroundColor: AppConstants.charcoal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: enquiryState.isSubmitting
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('SUBMIT INQUIRY NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
