import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../widgets/mobile_bottom_nav.dart';

class MobileServicesLayout extends StatelessWidget {
  const MobileServicesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.deepGreen,
        title: const Text('Our Services'),
      ),
      bottomNavigationBar: const MobileBottomNav(currentIndex: 3),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.services.length,
        itemBuilder: (context, index) {
          final item = AppConstants.services[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: AppTheme.glassCardDecoration(),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.deepGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getIconData(item['icon']!), color: AppConstants.primaryGold, size: 24),
              ),
              title: Text(
                item['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item['desc']!,
                  style: TextStyle(fontSize: 12, color: AppConstants.charcoal.withValues(alpha: 0.75)),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppConstants.primaryGold),
                onPressed: () => context.push('/enquiry?service=${Uri.encodeComponent(item['title']!)}'),
              ),
              onTap: () => context.push('/enquiry?service=${Uri.encodeComponent(item['title']!)}'),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'kaaba':
        return Icons.mosque;
      case 'moon':
        return Icons.nightlight_round;
      case 'plane':
        return Icons.flight;
      case 'passport':
        return Icons.badge;
      case 'hotel':
        return Icons.apartment;
      case 'shield':
        return Icons.security;
      case 'money':
        return Icons.payments;
      case 'map':
        return Icons.map;
      default:
        return Icons.travel_explore;
    }
  }
}
