import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      authNotifier.sendPhoneOtp(
        rawPhone: _phoneController.text.trim(),
        onCodeSentSuccess: () {
          context.push('/otp', extra: {
            'fullName': _nameController.text.trim(),
          });
        },
        onError: (errorMsg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppConstants.softCream,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.deepGreen.withValues(alpha: 0.05),
              AppConstants.softCream,
              AppConstants.primaryGold.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 460 : double.infinity,
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.glassCardDecoration(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Crescent & Star Islamic Icon Accent
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppConstants.deepGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryGold.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque,
                            size: 40,
                            color: AppConstants.primaryGold,
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
                        const SizedBox(height: 20),

                        // Title & Subtitle
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.deepGreen,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppConstants.tagline,
                          textAlign: TextAlign.center,
                          style: AppTheme.islamicAccentStyle(
                            fontSize: 14,
                            color: AppConstants.primaryGold,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Divider with Gold Star
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppConstants.borderGold)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '﷽',
                                style: AppTheme.islamicAccentStyle(
                                  fontSize: 18,
                                  color: AppConstants.deepGreen,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppConstants.borderGold)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Full Name Input (Optional)
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full Name (Optional)',
                            prefixIcon: Icon(Icons.person_outline, color: AppConstants.deepGreen),
                            hintText: 'e.g. Haji Mohammed Salim',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone Input with +91 Prefix
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number *',
                            hintText: '9876543210',
                            counterText: '',
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(14),
                              child: const Text(
                                '+91 ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.deepGreen,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter mobile number';
                            }
                            final digitsOnly = value.trim().replaceAll(RegExp(r'\D'), '');
                            if (digitsOnly.length != 10) {
                              return 'Enter valid 10-digit Indian mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Send OTP Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _onSendOtpPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryGold,
                              foregroundColor: AppConstants.charcoal,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppConstants.charcoal,
                                    ),
                                  )
                                : const Text(
                                    'SEND VERIFICATION CODE',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Continue as Guest Option
                        TextButton.icon(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                          icon: const Icon(Icons.arrow_back, size: 16, color: AppConstants.deepGreen),
                          label: const Text(
                            'Continue as Guest (Browse Packages)',
                            style: TextStyle(
                              color: AppConstants.deepGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Disclaimer Footer
                        Text(
                          'By proceeding, you agree to receive SMS verification for your Hajj & Umrah booking from Jamal Tours & Travels.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.charcoal.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
