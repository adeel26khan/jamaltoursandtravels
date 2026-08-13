import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/app_footer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchWhatsApp(String phone) async {
    final url = Uri.parse('https://wa.me/918929175340');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _sendEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isWebDesktop(context);

    return Scaffold(
      appBar: isDesktop
          ? const WebNavbar(activeRoute: '/enquiry')
          : AppBar(
              backgroundColor: AppConstants.deepGreen,
              title: const Text('Contact Us'),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: isDesktop ? 60 : 24),
              color: AppConstants.deepGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Home  /  Contact Us', style: TextStyle(color: AppConstants.primaryGold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'Get in Touch with Jamal Tours & Travels',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap below to call, WhatsApp, email, or visit our head office in Mira Road East, Thane.',
                    style: TextStyle(
                      color: AppConstants.warmWhite.withValues(alpha: 0.85),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Tap-to-Action Contact Cards Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24, vertical: 48),
              child: Column(
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      // 1. Phone Call Action Card
                      _ActionContactCard(
                        icon: Icons.phone_in_talk,
                        title: 'Landline Phone',
                        detail: AppConstants.phone,
                        actionLabel: 'TAP TO CALL NOW',
                        onTap: () => _makePhoneCall(AppConstants.phone),
                      ),

                      // 2. WhatsApp Action Card
                      _ActionContactCard(
                        icon: Icons.chat,
                        title: 'WhatsApp Helpline',
                        detail: AppConstants.whatsapp,
                        actionLabel: 'OPEN WHATSAPP CHAT',
                        buttonColor: const Color(0xFF25D366),
                        onTap: () => _launchWhatsApp(AppConstants.whatsapp),
                      ),

                      // 3. Email Action Card
                      _ActionContactCard(
                        icon: Icons.email,
                        title: 'Official Email',
                        detail: AppConstants.email,
                        actionLabel: 'SEND EMAIL',
                        onTap: () => _sendEmail(AppConstants.email),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Office Address & Working Hours Card
                  Container(
                    width: isDesktop ? 800 : double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: AppTheme.glassCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppConstants.deepGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.location_on, color: AppConstants.primaryGold, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'HEAD OFFICE LOCATION',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.deepGreen,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        Text(AppConstants.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.deepGreen)),
                        const SizedBox(height: 6),
                        Text(AppConstants.address, style: const TextStyle(fontSize: 14, height: 1.4)),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Icon(Icons.access_time, color: AppConstants.primaryGold, size: 18),
                            const SizedBox(width: 8),
                            Text('Working Hours: ${AppConstants.workingHours}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.badge, color: AppConstants.primaryGold, size: 18),
                            const SizedBox(width: 8),
                            Text('GSTIN: ${AppConstants.gstNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/enquiry'),
                            icon: const Icon(Icons.send, color: AppConstants.charcoal),
                            label: const Text('FILL ONLINE INQUIRY FORM'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryGold,
                              foregroundColor: AppConstants.charcoal,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isDesktop) const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class _ActionContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final String actionLabel;
  final Color? buttonColor;
  final VoidCallback onTap;

  const _ActionContactCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.actionLabel,
    this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppConstants.deepGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppConstants.primaryGold, size: 28),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(detail, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? AppConstants.primaryGold,
                foregroundColor: buttonColor != null ? Colors.white : AppConstants.charcoal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
