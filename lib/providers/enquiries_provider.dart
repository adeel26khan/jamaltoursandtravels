import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/enquiry_model.dart';
import 'supabase_provider.dart';

class EnquiryState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final List<EnquiryModel> enquiries;

  EnquiryState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    List<EnquiryModel>? enquiries,
  }) : enquiries = enquiries ??
            [
              EnquiryModel(
                id: 'enq_1',
                name: 'Mohammed Ibrahim',
                phone: '9820198201',
                email: 'ibrahim@example.com',
                packageInterest: 'Ramzan Full Month Umrah',
                numPilgrims: 2,
                status: 'new',
              ),
              EnquiryModel(
                id: 'enq_2',
                name: 'Fatima Shaikh',
                phone: '9870198701',
                packageInterest: 'Hajj 2026 Executive',
                numPilgrims: 4,
                status: 'contacted',
              ),
            ];

  EnquiryState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    List<EnquiryModel>? enquiries,
  }) {
    return EnquiryState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      enquiries: enquiries ?? this.enquiries,
    );
  }
}

class EnquiryNotifier extends StateNotifier<EnquiryState> {
  final Ref _ref;

  EnquiryNotifier(this._ref) : super(EnquiryState());

  Future<bool> submitEnquiry({
    required String name,
    required String phone,
    String? email,
    String? packageInterest,
    DateTime? preferredDate,
    int numPilgrims = 1,
    String? message,
  }) async {
    state = state.copyWith(isSubmitting: true, isSuccess: false, errorMessage: null);

    final newEnquiry = EnquiryModel(
      id: 'enq_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      packageInterest: packageInterest ?? 'Umrah Package',
      preferredDate: preferredDate,
      numPilgrims: numPilgrims,
      message: message,
      status: 'new',
    );

    // 1. Save to Supabase Database
    final supabase = _ref.read(supabaseClientProvider);
    if (supabase != null) {
      try {
        final data = {
          'name': name,
          'phone': phone,
          'email': email,
          'package_interest': packageInterest,
          'preferred_date': preferredDate?.toIso8601String().split('T').first,
          'num_pilgrims': numPilgrims,
          'message': message,
          'status': 'new',
        };

        await supabase.from('enquiries').insert(data);
      } catch (e) {
        debugPrint('Supabase Enquiry Insert Error: $e');
      }
    }

    // 2. Dispatch Instant Free Email Notification (Web3Forms API)
    try {
      await http.post(
        Uri.parse('https://api.web3forms.com/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_key': 'e84b8d1b-7a1b-4f90-8e12-jamaltours_free', // Replace with your free Web3Forms access key
          'subject': '🔔 New Hajj/Umrah Enquiry: $name ($phone)',
          'from_name': 'Jamal Tours Website',
          'name': name,
          'phone': phone,
          'email': email ?? 'N/A',
          'package_interest': packageInterest ?? 'General Umrah Enquiry',
          'num_pilgrims': numPilgrims,
          'message': message ?? 'No additional message',
        }),
      );
    } catch (_) {}

    final updated = [newEnquiry, ...state.enquiries];
    state = state.copyWith(isSubmitting: false, isSuccess: true, enquiries: updated);
    return true;
  }

  void updateEnquiryStatus(String enquiryId, String newStatus) async {
    final supabase = _ref.read(supabaseClientProvider);
    if (supabase != null) {
      try {
        await supabase.from('enquiries').update({'status': newStatus}).eq('id', enquiryId);
      } catch (_) {}
    }

    final updated = state.enquiries.map((e) {
      if (e.id == enquiryId) {
        return EnquiryModel(
          id: e.id,
          name: e.name,
          phone: e.phone,
          email: e.email,
          packageInterest: e.packageInterest,
          preferredDate: e.preferredDate,
          numPilgrims: e.numPilgrims,
          message: e.message,
          status: newStatus,
          createdAt: e.createdAt,
        );
      }
      return e;
    }).toList();

    state = state.copyWith(enquiries: updated);
  }

  void deleteEnquiry(String enquiryId) async {
    final supabase = _ref.read(supabaseClientProvider);
    if (supabase != null) {
      try {
        await supabase.from('enquiries').delete().eq('id', enquiryId);
      } catch (_) {}
    }

    final updated = state.enquiries.where((e) => e.id != enquiryId).toList();
    state = state.copyWith(enquiries: updated);
  }

  void reset() {
    state = EnquiryState(enquiries: state.enquiries);
  }
}

final enquiryProvider =
    StateNotifierProvider<EnquiryNotifier, EnquiryState>((ref) {
  return EnquiryNotifier(ref);
});

final adminEnquiriesProvider = FutureProvider<List<EnquiryModel>>((ref) async {
  final enquiriesState = ref.watch(enquiryProvider);
  return enquiriesState.enquiries;
});
