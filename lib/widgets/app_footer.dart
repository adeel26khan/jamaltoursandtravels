import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/responsive_utils.dart';
import 'app_logo.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      color: AppConstants.deepGreen,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 24,
        vertical: 48,
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildCompanyInfo(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildQuickLinks(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildServicesList(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 3, child: _buildContactInfo(context)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyInfo(context),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildQuickLinks(context)),
                      Expanded(child: _buildServicesList(context)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildContactInfo(context),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(color: AppConstants.borderGold, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© ${DateTime.now().year} ${AppConstants.appName}. All Rights Reserved.',
                style: TextStyle(
                  color: AppConstants.warmWhite.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              Text(
                'GSTIN: ${AppConstants.gstNumber}',
                style: const TextStyle(
                  color: AppConstants.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 12),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.warmWhite,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          AppConstants.tagline,
          style: AppTheme.islamicAccentStyle(fontSize: 14, color: AppConstants.primaryGold),
        ),
        const SizedBox(height: 12),
        Text(
          'Jamal Tours & Travels is a premier, government-recognized Hajj & Umrah tour operator based in Mira Road, Thane. Dedicated to providing sacred journeys with dignity, comfort, and scholar-guided excellence.',
          style: TextStyle(
            color: AppConstants.warmWhite.withValues(alpha: 0.8),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK LINKS',
          style: TextStyle(
            color: AppConstants.primaryGold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _FooterLink(title: 'Home', onTap: () => context.go('/')),
        _FooterLink(title: 'All Packages', onTap: () => context.go('/packages')),
        _FooterLink(title: 'Hajj Packages', onTap: () => context.go('/packages?type=hajj')),
        _FooterLink(title: 'Umrah Packages', onTap: () => context.go('/packages?type=umrah')),
        _FooterLink(title: 'Enquiry / Lead', onTap: () => context.go('/enquiry')),
      ],
    );
  }

  Widget _buildServicesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUR SERVICES',
          style: TextStyle(
            color: AppConstants.primaryGold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _FooterLink(title: 'Hajj Packages', onTap: () => context.go('/services')),
        _FooterLink(title: 'Umrah Packages', onTap: () => context.go('/services')),
        _FooterLink(title: 'Air Ticketing', onTap: () => context.go('/services')),
        _FooterLink(title: 'Visa Assistance', onTap: () => context.go('/services')),
        _FooterLink(title: 'Ziyarat Tours', onTap: () => context.go('/services')),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTACT & LOCATION',
          style: TextStyle(
            color: AppConstants.primaryGold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _ContactRow(icon: Icons.location_on, text: AppConstants.address),
        const SizedBox(height: 10),
        _ContactRow(icon: Icons.phone, text: AppConstants.phone),
        const SizedBox(height: 10),
        _ContactRow(icon: Icons.chat, text: 'WhatsApp: ${AppConstants.whatsapp}'),
        const SizedBox(height: 10),
        _ContactRow(icon: Icons.email, text: AppConstants.email),
        const SizedBox(height: 10),
        _ContactRow(icon: Icons.access_time, text: AppConstants.workingHours),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _FooterLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: AppConstants.warmWhite.withValues(alpha: 0.85),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConstants.primaryGold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppConstants.warmWhite.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
