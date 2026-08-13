import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import 'auth_provider.dart';
import 'supabase_provider.dart';

final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.profile == null) return [];

  final supabase = ref.watch(supabaseClientProvider);
  if (supabase == null) return [];

  try {
    final data = await supabase
        .from('bookings')
        .select()
        .eq('user_id', authState.profile!.id)
        .order('created_at', ascending: false);
    return (data as List).map((json) => BookingModel.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

class BookingCreateState {
  final bool isSubmitting;
  final String? bookingId;
  final String? errorMessage;

  BookingCreateState({
    this.isSubmitting = false,
    this.bookingId,
    this.errorMessage,
  });

  BookingCreateState copyWith({
    bool? isSubmitting,
    String? bookingId,
    String? errorMessage,
  }) {
    return BookingCreateState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      bookingId: bookingId ?? this.bookingId,
      errorMessage: errorMessage,
    );
  }
}

class BookingsNotifier extends StateNotifier<BookingCreateState> {
  final Ref _ref;

  BookingsNotifier(this._ref) : super(BookingCreateState());

  Future<String?> createBooking({
    required String packageId,
    required DateTime travelDate,
    required int numPilgrims,
    required double totalAmount,
    required List<Map<String, String>> pilgrimDetails,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final authState = _ref.read(authProvider);
    final userId = authState.profile?.id ?? 'guest_user';
    final supabase = _ref.read(supabaseClientProvider);

    if (supabase != null) {
      try {
        final bookingData = {
          'user_id': userId,
          'package_id': packageId,
          'status': 'pending',
          'travel_date': travelDate.toIso8601String().split('T').first,
          'num_pilgrims': numPilgrims,
          'total_amount': totalAmount,
          'payment_status': 'unpaid',
        };

        final response = await supabase
            .from('bookings')
            .insert(bookingData)
            .select()
            .single();

        final bookingId = response['id'] as String;

        // Insert pilgrims
        final pilgrimsList = pilgrimDetails.map((p) => {
          'booking_id': bookingId,
          'full_name': p['full_name'] ?? 'Pilgrim',
          'passport_number': p['passport_number'],
          'gender': p['gender'] ?? 'male',
          'relation': p['relation'] ?? 'Self',
        }).toList();

        if (pilgrimsList.isNotEmpty) {
          await supabase.from('pilgrims').insert(pilgrimsList);
        }

        state = state.copyWith(isSubmitting: false, bookingId: bookingId);
        _ref.invalidate(userBookingsProvider);
        return bookingId;
      } catch (_) {}
    }

    // Fallback mock booking ID for preview
    final mockBookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(isSubmitting: false, bookingId: mockBookingId);
    return mockBookingId;
  }

  Future<void> updatePaymentStatus(String bookingId, String paymentStatus) async {
    final supabase = _ref.read(supabaseClientProvider);
    if (supabase == null) return;

    try {
      await supabase.from('bookings').update({
        'payment_status': paymentStatus,
        'status': paymentStatus == 'paid' ? 'confirmed' : 'pending',
      }).eq('id', bookingId);
      _ref.invalidate(userBookingsProvider);
    } catch (_) {}
  }
}

final bookingCreateProvider =
    StateNotifierProvider<BookingsNotifier, BookingCreateState>((ref) {
  return BookingsNotifier(ref);
});
