import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize Supabase gracefully
  try {
    final url = AppConstants.supabaseUrl != 'https://placeholder.supabase.co'
        ? AppConstants.supabaseUrl
        : 'https://jamal-tours.supabase.co';
    final key = AppConstants.supabaseAnonKey != 'placeholder_key'
        ? AppConstants.supabaseAnonKey
        : 'sbp_placeholder_anon_key';

    await Supabase.initialize(
      url: url,
      publishableKey: key,
    );
  } catch (e) {
    debugPrint('Supabase initialization deferred: $e');
  }

  // Initialize Firebase gracefully
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization deferred: $e');
  }

  runApp(
    const ProviderScope(
      child: JamalToursApp(),
    ),
  );
}

class JamalToursApp extends StatelessWidget {
  const JamalToursApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
