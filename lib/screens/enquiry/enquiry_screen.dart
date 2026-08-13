import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';
import 'web_enquiry_layout.dart';
import 'mobile_enquiry_layout.dart';

class EnquiryScreen extends StatelessWidget {
  final String? initialService;
  const EnquiryScreen({super.key, this.initialService});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isWebDesktop(context)
        ? WebEnquiryLayout(initialService: initialService)
        : MobileEnquiryLayout(initialService: initialService);
  }
}
