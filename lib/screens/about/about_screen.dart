import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../widgets/web_navbar.dart';
import '../../widgets/app_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isWebDesktop(context);

    return Scaffold(
      appBar: isDesktop
          ? const WebNavbar(activeRoute: '/about')
          : AppBar(
              backgroundColor: AppConstants.deepGreen,
              title: const Text('About Jamal Tours'),
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
                  const Text('Home  /  About Us', style: TextStyle(color: AppConstants.primaryGold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'Our Sacred Journey, Our Trusted Promise',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppConstants.warmWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Serving pilgrims from Mumbai, Thane & Maharashtra for over a decade with spiritual excellence.',
                    style: TextStyle(
                      color: AppConstants.warmWhite.withValues(alpha: 0.85),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // 1. Company Story Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24, vertical: 48),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _buildStoryText(context)),
                        const SizedBox(width: 48),
                        Expanded(child: _buildStoryImageCard(context)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildStoryImageCard(context),
                      const SizedBox(height: 32),
                      _buildStoryText(context),
                    ],
                  );
                },
              ),
            ),

            // 2. Count-Up Stats Counter Section
            Container(
              color: AppConstants.deepGreen,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: isDesktop ? 60 : 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stats = [
                    {'num': '50,000+', 'label': 'Happy Pilgrims Served'},
                    {'num': '10+ Years', 'label': 'Excellence in Hajj & Umrah'},
                    {'num': '100%', 'label': 'Visa Success Clearance'},
                    {'num': '5-Star', 'label': 'Haram Facing Luxury Hotels'},
                  ];

                  if (constraints.maxWidth > 700) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: stats
                          .map((s) => Column(
                                children: [
                                  Text(
                                    s['num']!,
                                    style: const TextStyle(
                                      color: AppConstants.primaryGold,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).animate().scale(duration: 400.ms),
                                  const SizedBox(height: 4),
                                  Text(
                                    s['label']!,
                                    style: TextStyle(
                                      color: AppConstants.warmWhite.withValues(alpha: 0.85),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    );
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    children: stats
                        .map((s) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s['num']!,
                                  style: const TextStyle(
                                    color: AppConstants.primaryGold,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  s['label']!,
                                  style: TextStyle(
                                    color: AppConstants.warmWhite.withValues(alpha: 0.85),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  );
                },
              ),
            ),

            // 3. Government Accreditations & Certifications Badges
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24, vertical: 48),
              child: Column(
                children: [
                  const Text(
                    'GOVERNMENT RECOGNITION & ACCREDITATIONS',
                    style: TextStyle(color: AppConstants.primaryGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Certified & Registered Tour Operator',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                  ),
                  const SizedBox(height: 32),

                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _BadgeCard(
                        icon: Icons.verified,
                        title: 'Govt. Recognized Operator',
                        subtitle: 'GSTIN: ${AppConstants.gstNumber}',
                      ),
                      _BadgeCard(
                        icon: Icons.mosque,
                        title: 'Ministry of Hajj & Umrah',
                        subtitle: 'Authorized Saudi Arabia Partner',
                      ),
                      _BadgeCard(
                        icon: Icons.flight,
                        title: 'IATA Accredited Agent',
                        subtitle: 'Direct Airline Flight Booking',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Leadership & Scholar Guides Team
            Container(
              color: AppConstants.deepGreen.withValues(alpha: 0.03),
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24, vertical: 48),
              child: Column(
                children: [
                  const Text(
                    'SCHOLARS & LEADERSHIP',
                    style: TextStyle(color: AppConstants.primaryGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Guided By Experience & Devotion',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                  ),
                  const SizedBox(height: 32),

                  Wrap(
                    spacing: 24,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _TeamCard(
                        name: 'Haji Jamaluddin Shaikh',
                        role: 'Founder & Managing Director',
                        desc: '20+ years in Saudi pilgrimage logistics and group travel operations.',
                      ),
                      _TeamCard(
                        name: 'Maulana Hafiz Mohammad Tariq',
                        role: 'Head Islamic Scholar Guide',
                        desc: 'Leads daily rituals, Tawaf, Sa\'i, and historical Ziyarat seminars in Makkah & Madinah.',
                      ),
                      _TeamCard(
                        name: 'Dr. Mohammed Tariq Ansari',
                        role: 'Medical & Support Operations',
                        desc: 'Dedicated 24/7 on-ground pilgrim care and medical emergency coordination.',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 5. Contact Banner CTA
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: isDesktop ? 60 : 24),
              color: AppConstants.softCream,
              child: Column(
                children: [
                  Text(
                    'Ready to Embark on Your Sacred Journey?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppConstants.deepGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/enquiry'),
                    icon: const Icon(Icons.send, color: AppConstants.charcoal),
                    label: const Text('CONTACT US TODAY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGold,
                      foregroundColor: AppConstants.charcoal,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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

  Widget _buildStoryText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUR HERITAGE & MISSION',
          style: TextStyle(color: AppConstants.primaryGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(
          'Serving Guests of Allah With Honor',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
        ),
        const SizedBox(height: 16),
        const Text(
          'Founded in Mira Road East, Thane, Jamal Tours & Travels has built a reputation of absolute trust, transparent pricing, and unmatched hospitality for Hajj & Umrah pilgrims.',
          style: TextStyle(fontSize: 15, height: 1.6, color: AppConstants.charcoal),
        ),
        const SizedBox(height: 12),
        const Text(
          'We handle every detail of your pilgrimage — from direct flight ticket reservations, fast Umrah visa clearance, and luxury 5-Star Haram facing hotel stays, to guided Ziyarat tours with experienced Islamic scholars.',
          style: TextStyle(fontSize: 15, height: 1.6, color: AppConstants.charcoal),
        ),
      ],
    );
  }

  Widget _buildStoryImageCard(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1542816417-0983cbe32277?auto=format&fit=crop&w=1000&q=80'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.deepGreen.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BadgeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppConstants.deepGreen, shape: BoxShape.circle),
            child: Icon(icon, color: AppConstants.primaryGold, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppConstants.deepGreen)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppConstants.charcoal.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String name;
  final String role;
  final String desc;

  const _TeamCard({
    required this.name,
    required this.role,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppConstants.deepGreen,
            child: Icon(Icons.person, color: AppConstants.primaryGold, size: 40),
          ),
          const SizedBox(height: 12),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.deepGreen)),
          Text(role, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.primaryGold)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppConstants.charcoal.withValues(alpha: 0.8), height: 1.4)),
        ],
      ),
    );
  }
}
