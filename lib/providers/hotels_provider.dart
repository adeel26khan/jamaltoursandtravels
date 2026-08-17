import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel_model.dart';
import 'supabase_provider.dart';

final mockHotels = [
  HotelModel(
    id: 'hotel_1',
    name: 'Pullman Zamzam Makkah',
    city: 'Makkah',
    starRating: 5,
    distanceFromHaram: '0 Meters (Direct Clock Tower View)',
    image: 'https://images.unsplash.com/photo-1542816417-0983cbe32277?auto=format&fit=crop&w=800&q=80',
  ),
  HotelModel(
    id: 'hotel_2',
    name: 'Swissotel Al Maqam Makkah',
    city: 'Makkah',
    starRating: 5,
    distanceFromHaram: '50 Meters from Haram Gate',
    image: 'https://images.unsplash.com/photo-1542816417-0983cbe32277?auto=format&fit=crop&w=800&q=80',
  ),
  HotelModel(
    id: 'hotel_3',
    name: 'Dar Al Taqwa Madinah',
    city: 'Madinah',
    starRating: 5,
    distanceFromHaram: '0 Meters (Facing Prophet\'s Mosque Gate 25)',
    image: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=800&q=80',
  ),
  HotelModel(
    id: 'hotel_4',
    name: 'Anwar Al Madinah Movenpick',
    city: 'Madinah',
    starRating: 5,
    distanceFromHaram: '100 Meters from Masjid An-Nabawi',
    image: 'https://images.unsplash.com/photo-1604881988758-f76ad2f7aac1?auto=format&fit=crop&w=800&q=80',
  ),
];

final hotelsProvider = FutureProvider<List<HotelModel>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase != null) {
    try {
      final response = await supabase.from('hotels').select('*').order('created_at', ascending: false);
      if ((response as List).isNotEmpty) {
        return (response as List).map((json) => HotelModel.fromJson(json)).toList();
      }
    } catch (_) {}
  }
  return ref.watch(hotelsCrudNotifierProvider);
});

class HotelsCrudNotifier extends StateNotifier<List<HotelModel>> {
  HotelsCrudNotifier() : super(mockHotels);

  void addHotel(HotelModel hotel) {
    state = [hotel, ...state];
  }

  void updateHotel(HotelModel updatedHotel) {
    state = state.map((h) => h.id == updatedHotel.id ? updatedHotel : h).toList();
  }

  void deleteHotel(String id) {
    state = state.where((h) => h.id != id).toList();
  }
}

final hotelsCrudNotifierProvider = StateNotifierProvider<HotelsCrudNotifier, List<HotelModel>>((ref) {
  return HotelsCrudNotifier();
});
