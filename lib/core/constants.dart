import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Jamal Tours & Travels';
  static const String tagline = 'Your Sacred Journey, Our Trusted Promise';
  static const String appLogo = 'assets/icons/app_logo.png';
  
  // Business Info
  static const String address = '1st Floor, School Road, Near NH School, Mira Road East, Thane, Maharashtra 401107';
  static const String phone = '022-28101099';
  static const String whatsapp = '+91-8929175340';
  static const String email = 'info@jamalhajumrahtoursntravels.com';
  static const String gstNumber = '27COYPS5955N1ZH';
  static const String workingHours = 'Mon–Sun, 10:00 AM – 8:30 PM';

  // Supabase Config
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://rvfgkqroidhcvwloxloo.supabase.co');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_MFAmFw54tVv3zpoPdZZx1Q_3rcZr1zT');

  // Razorpay Test Key Placeholder
  static const String razorpayApiKey = String.fromEnvironment('RAZORPAY_KEY', defaultValue: 'rzp_test_placeholder');

  // Design Tokens - Color Palette
  static const Color primaryGold = Color(0xFFC5A059);
  static const Color deepGreen = Color(0xFF0B3D2E);
  static const Color softCream = Color(0xFFFDF8F0);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color warmWhite = Color(0xFFFFFFFF);
  static const Color accentTeal = Color(0xFF2D6A4F);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color borderGold = Color(0xFFE5C98B);
  static const Color cardShadow = Color(0x1A0B3D2E);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  // Services offered
  static const List<Map<String, String>> services = [
    {'title': 'Hajj Package Booking', 'icon': 'kaaba', 'desc': 'Complete guided Hajj package with VIP tents & scholar support.'},
    {'title': 'Umrah Package Booking', 'icon': 'moon', 'desc': 'Customized & fixed group Umrah packages year round.'},
    {'title': 'Air Ticketing', 'icon': 'plane', 'desc': 'Best fares for direct & connecting flights to Saudi Arabia.'},
    {'title': 'Visa Assistance', 'icon': 'passport', 'desc': 'Fast Umrah & Tourist visa processing with document guidance.'},
    {'title': 'Hotel Reservations', 'icon': 'hotel', 'desc': 'Luxury 5-Star & 3-Star accommodations near Haram.'},
    {'title': 'Travel Insurance', 'icon': 'shield', 'desc': 'Comprehensive overseas medical & travel coverage.'},
    {'title': 'Forex Services', 'icon': 'money', 'desc': 'Best SAR currency exchange rates for your sacred trip.'},
    {'title': 'Ziyarat Tours', 'icon': 'map', 'desc': 'Guided tours to sacred historical sites in Makkah & Madinah.'},
  ];
}
