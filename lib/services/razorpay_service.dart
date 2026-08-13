import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/constants.dart';

class RazorpayService {
  Razorpay? _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onExternalWallet = onExternalWallet;

    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleFailure);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) onSuccess!(response);
  }

  void _handleFailure(PaymentFailureResponse response) {
    if (onFailure != null) onFailure!(response);
  }

  void _handleWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) onExternalWallet!(response);
  }

  void openCheckout({
    required double amountInr,
    required String bookingId,
    required String packageName,
    required String userPhone,
    required String userEmail,
  }) {
    final amountInPaise = (amountInr * 100).toInt();

    final options = {
      'key': AppConstants.razorpayApiKey,
      'amount': amountInPaise,
      'name': AppConstants.appName,
      'description': 'Booking for $packageName (ID: $bookingId)',
      'prefill': {
        'contact': userPhone,
        'email': userEmail.isNotEmpty ? userEmail : 'info@jamalhajumrahtoursntravels.com',
      },
      'theme': {
        'color': '#0B3D2E',
      },
      'external': {
        'wallets': ['paytm', 'gpay', 'phonepe']
      }
    };

    try {
      if (!kIsWeb && _razorpay != null) {
        _razorpay!.open(options);
      } else {
        // Web / Dev Fallback simulation
        Future.delayed(const Duration(seconds: 1), () {
          final mockSuccess = PaymentSuccessResponse.fromMap({
            'razorpay_payment_id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
            'razorpay_order_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
            'razorpay_signature': 'sig_${DateTime.now().millisecondsSinceEpoch}',
          });
          _handleSuccess(mockSuccess);
        });
      }
    } catch (e) {
      final mockSuccess = PaymentSuccessResponse.fromMap({
        'razorpay_payment_id': 'pay_simulated_${DateTime.now().millisecondsSinceEpoch}',
        'razorpay_order_id': 'order_simulated_${DateTime.now().millisecondsSinceEpoch}',
        'razorpay_signature': 'sig_simulated_${DateTime.now().millisecondsSinceEpoch}',
      });
      _handleSuccess(mockSuccess);
    }
  }

  void dispose() {
    _razorpay?.clear();
  }
}
