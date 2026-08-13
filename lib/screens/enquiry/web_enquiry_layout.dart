import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/enquiries_provider.dart';
import '../../providers/packages_provider.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/app_footer.dart';

class WebEnquiryLayout extends ConsumerStatefulWidget {
  final String? initialService;
  const WebEnquiryLayout({super.key, this.initialService});

  @override
  ConsumerState<WebEnquiryLayout> createState() => _WebEnquiryLayoutState();
}

class _WebEnquiryLayoutState extends ConsumerState<WebEnquiryLayout> {
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
    final message = Uri.encodeComponent(
        "Assalamu Alaikum! I am $name. I would like to enquire about $pkg with Jamal Tours & Travels.");
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
        packageInterest: _selectedPackageInterest ?? 'Ramzan Full Month Umrah',
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
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppConstants.deepGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: AppConstants.primaryGold, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enquiry Submitted Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                ),
              ],
            ),
            content: Text(
              'JazakAllah Khair $userName! Our Hajj & Umrah travel experts will call you shortly on +91 ${_phoneController.text.trim()}.\n\nFor immediate assistance, chat with us on WhatsApp.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchWhatsApp(userName, userPkg);
                },
                icon: const Icon(Icons.chat, color: AppConstants.charcoal),
                label: const Text('CHAT ON WHATSAPP'),
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
                  _emailController.clear();
                  _messageController.clear();
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
      appBar: const WebNavbar(activeRoute: '/enquiry'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
              color: AppConstants.deepGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home  /  Contact & Custom Package Inquiry',
                    style: TextStyle(color: AppConstants.primaryGold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get in Touch with Our Sacred Travel Experts',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Have questions about Ramzan Umrah, Hajj 2026, air tickets, or custom itineraries? Send us a message below.',
                    style: TextStyle(
                      color: AppConstants.warmWhite.withValues(alpha: 0.85),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Split 2-Column Section (Form Left, Contact Info Right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Form Column (Flex 3)
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: AppTheme.glassCardDecoration(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CUSTOM INQUIRY FORM',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.deepGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(height: 3, width: 40, color: AppConstants.primaryGold),
                            const SizedBox(height: 24),

                            // Name & Phone Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name *',
                                      prefixIcon: Icon(Icons.person, color: AppConstants.deepGreen),
                                    ),
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    decoration: const InputDecoration(
                                      labelText: 'Mobile Number (+91) *',
                                      counterText: '',
                                      prefixIcon: Icon(Icons.phone, color: AppConstants.deepGreen),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Phone required';
                                      if (val.trim().replaceAll(RegExp(r'\D'), '').length != 10) {
                                        return 'Enter 10-digit number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Email & Package Interest Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address (Optional)',
                                      prefixIcon: Icon(Icons.email, color: AppConstants.deepGreen),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: packagesAsync.when(
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
                                        decoration: const InputDecoration(
                                          labelText: 'Package or Service of Interest',
                                          prefixIcon: Icon(Icons.mosque, color: AppConstants.deepGreen),
                                        ),
                                        items: options
                                            .map((title) => DropdownMenuItem(
                                                  value: title,
                                                  child: Text(title, overflow: TextOverflow.ellipsis),
                                                ))
                                            .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedPackageInterest = val;
                                          });
                                        },
                                      );
                                    },
                                    loading: () => const SizedBox(),
                                    error: (err, stack) => const SizedBox(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Preferred Date & Pilgrims Row
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().add(const Duration(days: 14)),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _preferredDate = date;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Preferred Travel Month/Date',
                                        prefixIcon: Icon(Icons.calendar_today, color: AppConstants.deepGreen),
                                      ),
                                      child: Text(
                                        _preferredDate != null
                                            ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                                            : 'Select Date',
                                        style: TextStyle(
                                          color: _preferredDate != null ? AppConstants.charcoal : Colors.grey,
                                        ),
                                      ),
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
                                          child: Text(
                                            '$_numPilgrims Traveler(s)',
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Message Area
                            TextFormField(
                              controller: _messageController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Special Requests / Message',
                                alignLabelWithHint: true,
                                hintText: 'Tell us if you need customized hotel preferences, quad sharing, or wheelchair assistance...',
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: enquiryState.isSubmitting ? null : _onSubmitEnquiry,
                                icon: enquiryState.isSubmitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.charcoal),
                                      )
                                    : const Icon(Icons.send, color: AppConstants.charcoal),
                                label: Text(
                                  enquiryState.isSubmitting ? 'SUBMITTING...' : 'SUBMIT ENQUIRY NOW',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryGold,
                                  foregroundColor: AppConstants.charcoal,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Right Contact Cards Column (Flex 2)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Official Business Info Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.glassCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HEAD OFFICE LOCATION',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryGold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppConstants.appName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                              ),
                              const SizedBox(height: 16),
                              _InfoItem(icon: Icons.location_on, title: 'Address', detail: AppConstants.address),
                              const SizedBox(height: 12),
                              _InfoItem(icon: Icons.phone, title: 'Landline Phone', detail: AppConstants.phone),
                              const SizedBox(height: 12),
                              _InfoItem(icon: Icons.chat, title: 'WhatsApp Helpline', detail: AppConstants.whatsapp),
                              const SizedBox(height: 12),
                              _InfoItem(icon: Icons.email, title: 'Official Email', detail: AppConstants.email),
                              const SizedBox(height: 12),
                              _InfoItem(icon: Icons.access_time, title: 'Working Hours', detail: AppConstants.workingHours),
                              const SizedBox(height: 12),
                              _InfoItem(icon: Icons.badge, title: 'GST Registration', detail: AppConstants.gstNumber),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // WhatsApp Direct Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF25D366)),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.chat, color: Color(0xFF25D366), size: 28),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Need Instant Assistance?',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                                        ),
                                        Text(
                                          'Connect directly with our tour scholar on WhatsApp',
                                          style: TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _launchWhatsApp('Pilgrim', 'Hajj / Umrah Packages'),
                                  icon: const Icon(Icons.chat, color: Colors.white),
                                  label: const Text('OPEN WHATSAPP CHAT'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _InfoItem({required this.icon, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppConstants.primaryGold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(detail, style: const TextStyle(fontSize: 13, color: AppConstants.charcoal, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
