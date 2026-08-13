import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? fullName;

  const OtpScreen({super.key, this.fullName});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onVerifyPressed() {
    final code = _otpCode;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the OTP code'),
          backgroundColor: Colors.deepOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.verifyOtp(
      otpCode: code,
      fullName: widget.fullName,
      onSuccess: (isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAdmin
                ? 'Welcome Admin! Redirecting to Admin Dashboard...'
                : 'Login successful! Welcome to Jamal Tours & Travels.'),
            backgroundColor: AppConstants.deepGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (isAdmin) {
          context.go('/admin');
        } else if (context.canPop()) {
          context.pop();
          context.pop(); // Pop auth screens back to caller
        } else {
          context.go('/');
        }
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

  void _onResendPressed() {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    authNotifier.sendPhoneOtp(
      rawPhone: authState.phone,
      onCodeSentSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New OTP sent successfully to your mobile number.'),
            backgroundColor: AppConstants.deepGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppConstants.softCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.deepGreen),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 460 : double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.glassCardDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Lock / Shield Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.deepGreen.withValues(alpha: 0.1),
                        border: Border.all(color: AppConstants.primaryGold),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 36,
                        color: AppConstants.deepGreen,
                      ),
                    ).animate().scale(duration: 400.ms),
                    const SizedBox(height: 20),

                    Text(
                      'Enter Verification Code',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.deepGreen,
                          ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'We have sent a 6-digit SMS code to\n${authState.phone.isNotEmpty ? authState.phone : "+91 XXXXX XXXXX"}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.charcoal.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 6-digit OTP Box inputs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44,
                          height: 52,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.deepGreen,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppConstants.deepGreen, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppConstants.borderGold, width: 1.5),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              if (_otpCode.length == 6) {
                                _onVerifyPressed();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _onVerifyPressed,
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
                                'VERIFY & CONTINUE',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Resend Timer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive code? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.charcoal.withValues(alpha: 0.7),
                          ),
                        ),
                        if (authState.resendCountdown > 0)
                          Text(
                            'Resend in ${authState.resendCountdown}s',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryGold,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _onResendPressed,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.deepGreen,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
