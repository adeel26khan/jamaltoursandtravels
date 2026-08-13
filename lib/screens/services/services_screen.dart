import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';
import 'web_services_layout.dart';
import 'mobile_services_layout.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isWebDesktop(context)
        ? const WebServicesLayout()
        : const MobileServicesLayout();
  }
}
