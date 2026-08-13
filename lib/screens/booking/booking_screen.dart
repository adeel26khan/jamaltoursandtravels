import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';
import 'web_booking_layout.dart';
import 'mobile_booking_layout.dart';

class BookingScreen extends StatelessWidget {
  final String? packageId;

  const BookingScreen({super.key, this.packageId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isWebDesktop(context)
        ? WebBookingLayout(packageId: packageId)
        : MobileBookingLayout(packageId: packageId);
  }
}
