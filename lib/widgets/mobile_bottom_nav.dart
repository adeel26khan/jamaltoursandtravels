import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;

  const MobileBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/packages');
            break;
          case 2:
            context.go('/enquiry');
            break;
          case 3:
            context.go('/services');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_travel_outlined),
          activeIcon: Icon(Icons.card_travel),
          label: 'Packages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.send_outlined),
          activeIcon: Icon(Icons.send),
          label: 'Enquiry',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.room_service_outlined),
          activeIcon: Icon(Icons.room_service),
          label: 'Services',
        ),
      ],
    );
  }
}
