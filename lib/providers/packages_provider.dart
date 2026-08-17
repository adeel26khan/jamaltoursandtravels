import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_model.dart';
import '../models/itinerary_model.dart';
import '../models/testimonial_model.dart';
import 'supabase_provider.dart';

final packagesProvider = FutureProvider<List<PackageModel>>((ref) async {
  final crudList = ref.watch(packagesCrudNotifierProvider);

  final supabase = ref.watch(supabaseClientProvider);
  if (supabase != null) {
    try {
      final data = await supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .order('price_inr', ascending: true);

      final list = (data as List).map((e) => PackageModel.fromJson(e)).toList();
      if (list.isNotEmpty) {
        final existingIds = list.map((e) => e.id).toSet();
        final localAdded = crudList.where((p) => !existingIds.contains(p.id)).toList();
        return [...localAdded, ...list];
      }
    } catch (_) {}
  }

  // Fallback seed packages + local CRUD added packages
  final seedPackages = [
    PackageModel(
      id: 'ramzan-full-month-2026',
      title: 'Ramzan Full Month Executive Umrah Package 2026',
      type: 'umrah',
      description: 'Experience the entire holy month of Ramzan in Makkah & Madinah with 5-Star luxury Haram facing accommodation.',
      durationDays: 30,
      makkahNights: 15,
      madinahNights: 15,
      priceInr: 185000.0,
      originalPriceInr: 205000.0,
      badge: 'RAMZAN SPECIAL',
      maxSeats: 50,
      availableSeats: 12,
      images: [
        'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80',
      ],
      createdAt: DateTime.now(),
    ),
    PackageModel(
      id: 'ramzan-1st-20-days-2026',
      title: 'Ramzan 1st 20 Days Premium Umrah Package 2026',
      type: 'umrah',
      description: 'Spend the first 20 days of Ramzan in Makkah & Madinah with direct flight air tickets and scholar guided Ziyarat.',
      durationDays: 20,
      makkahNights: 10,
      madinahNights: 10,
      priceInr: 145000.0,
      badge: 'POPULAR',
      maxSeats: 40,
      availableSeats: 8,
      images: [
        'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80',
      ],
      createdAt: DateTime.now(),
    ),
    PackageModel(
      id: 'hajj-premium-2026',
      title: 'Hajj 2026 Premium Deluxe Shifting Package',
      type: 'hajj',
      description: 'Complete Hajj package with Mina AC tents, Azizia accommodation, 5-Star Makkah/Madinah hotel stay, and guidance by renowned scholars.',
      durationDays: 40,
      makkahNights: 25,
      madinahNights: 15,
      priceInr: 650000.0,
      badge: 'HAJJ 2026',
      maxSeats: 30,
      availableSeats: 5,
      images: [
        'https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?auto=format&fit=crop&w=1000&q=80',
      ],
      createdAt: DateTime.now(),
    ),
    PackageModel(
      id: 'air-ticket-saudi-airlines',
      title: 'Direct Flight Air Tickets Mumbai to Jeddah / Madinah',
      type: 'air_ticket',
      description: 'Confirmed round-trip group seats on Saudi Airlines and Flynas with 46kg luggage allowance.',
      durationDays: 15,
      makkahNights: 0,
      madinahNights: 0,
      priceInr: 58000.0,
      badge: 'FLIGHT ONLY',
      maxSeats: 100,
      availableSeats: 45,
      images: [
        'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&w=1000&q=80',
      ],
      createdAt: DateTime.now(),
    ),
  ];

  final existingIds = seedPackages.map((e) => e.id).toSet();
  final localAdded = crudList.where((p) => !existingIds.contains(p.id)).toList();
  return [...localAdded, ...seedPackages];
});

final packageDetailProvider = FutureProvider.family<PackageModel?, String>((ref, id) async {
  final packages = await ref.watch(packagesProvider.future);
  try {
    return packages.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

final packageItinerariesProvider = FutureProvider.family<List<PackageItineraryModel>, String>((ref, packageId) async {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase != null) {
    try {
      final response = await supabase
          .from('package_itineraries')
          .select('*')
          .eq('package_id', packageId)
          .order('day_number', ascending: true);

      if ((response as List).isNotEmpty) {
        return (response as List).map((json) => PackageItineraryModel.fromJson(json)).toList();
      }
    } catch (_) {}
  }

  return [
    PackageItineraryModel(
      id: 'it1',
      packageId: packageId,
      dayNumber: 1,
      city: 'Makkah',
      title: 'Arrival in Jeddah & Transfer to Makkah Mukarramah',
      description: 'Board direct flight to Jeddah Airport. Meet our tour representative, wear Ihram, and proceed in luxury AC coach to Makkah Mukarramah. Check into 5-Star Hotel and perform Umrah with Scholar.',
    ),
    PackageItineraryModel(
      id: 'it2',
      packageId: packageId,
      dayNumber: 2,
      city: 'Makkah',
      title: 'Rest & Ibadaat in Masjid Al-Haram',
      description: 'Full day reserved for Nawaafil, Quran recitation, and Tawaaf in Masjid Al-Haram.',
    ),
    PackageItineraryModel(
      id: 'it3',
      packageId: packageId,
      dayNumber: 3,
      city: 'Makkah',
      title: 'Historical Makkah Ziyarat Tour',
      description: 'Guided tour to Jabal al-Nour (Cave of Hira), Cave of Thawr, Mina, Arafat, and Muzdalifah in comfortable AC coaches.',
    ),
    PackageItineraryModel(
      id: 'it4',
      packageId: packageId,
      dayNumber: 15,
      city: 'Madinah',
      title: 'Transfer to Madinah Munawwarah & Salaam at Rawdah',
      description: 'Check out from Makkah and travel via Haramain High Speed Train or AC Coach to Madinah Munawwarah. Check into hotel near Al-Masjid an-Nabawi and present Salam at Rawdah Rasool (SAW).',
    ),
  ];
});

final testimonialsProvider = FutureProvider<List<TestimonialModel>>((ref) async {
  final crudTestimonials = ref.watch(testimonialsCrudNotifierProvider);
  if (crudTestimonials.isNotEmpty) return crudTestimonials;

  return [
    TestimonialModel(
      id: 't1',
      name: 'Haji Mohammed Salim Khan',
      city: 'Mumbai, Maharashtra',
      rating: 5,
      comment: 'Jamal Tours made our family Umrah completely hassle-free. The proximity of Swissotel to Haram in Makkah was exceptional.',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      createdAt: DateTime.now(),
    ),
    TestimonialModel(
      id: 't2',
      name: 'Fatima Sheikh',
      city: 'Thane, Maharashtra',
      rating: 5,
      comment: 'Transparent pricing, no hidden costs. The scholars guided us at every step during Ramzan Taraweeh and Ziyarat tours.',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      createdAt: DateTime.now(),
    ),
  ];
});

class PackagesCrudNotifier extends StateNotifier<List<PackageModel>> {
  PackagesCrudNotifier() : super([]);

  void addPackage(PackageModel package) {
    state = [package, ...state];
  }

  void updatePackage(PackageModel package) {
    state = state.map((p) => p.id == package.id ? package : p).toList();
  }

  void deletePackage(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final packagesCrudNotifierProvider =
    StateNotifierProvider<PackagesCrudNotifier, List<PackageModel>>((ref) {
  return PackagesCrudNotifier();
});

class TestimonialsCrudNotifier extends StateNotifier<List<TestimonialModel>> {
  TestimonialsCrudNotifier() : super([]);

  void addTestimonial(TestimonialModel t) {
    state = [t, ...state];
  }

  void deleteTestimonial(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final testimonialsCrudNotifierProvider =
    StateNotifierProvider<TestimonialsCrudNotifier, List<TestimonialModel>>((ref) {
  return TestimonialsCrudNotifier();
});

final galleryProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase != null) {
    try {
      final data = await supabase.from('gallery').select().eq('is_active', true);
      if ((data as List).isNotEmpty) {
        return (data as List).map((e) => {
          'title': e['title'] as String? ?? 'Sacred Moment',
          'category': e['category'] as String? ?? 'general',
          'location': e['location'] as String? ?? 'Makkah',
          'url': e['url'] as String? ?? 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
        }).toList();
      }
    } catch (_) {}
  }

  return const [
    {
      'title': 'Masjid Al-Haram & Holy Kaaba',
      'category': 'makkah',
      'location': 'Makkah Mukarramah',
      'url': 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Al-Masjid an-Nabawi Green Dome',
      'category': 'madinah',
      'location': 'Madinah Munawwarah',
      'url': 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Pilgrims Performing Tawaf',
      'category': 'makkah',
      'location': 'Masjid Al-Haram',
      'url': 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Sacred Madinah Courtyard',
      'category': 'madinah',
      'location': 'Madinah Munawwarah',
      'url': 'https://images.unsplash.com/photo-1604881988758-f76ad2f7aac1?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Grand Mosque Night View',
      'category': 'makkah',
      'location': 'Makkah Mukarramah',
      'url': 'https://images.unsplash.com/photo-1542816417-0983cbe32277?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Masjid Nabawi Umbrellas',
      'category': 'madinah',
      'location': 'Madinah Munawwarah',
      'url': 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80',
    },
  ];
});
