import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';
import 'web_home_layout.dart';
import 'mobile_home_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isWebDesktop(context)
        ? const WebHomeLayout()
        : const MobileHomeLayout();
  }
}
