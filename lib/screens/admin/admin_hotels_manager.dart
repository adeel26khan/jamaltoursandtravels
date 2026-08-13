import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../models/hotel_model.dart';
import '../../providers/hotels_provider.dart';
import '../../providers/supabase_provider.dart';

class AdminHotelsManager extends ConsumerWidget {
  const AdminHotelsManager({super.key});

  void _showHotelDialog(BuildContext context, WidgetRef ref, {HotelModel? existingHotel}) {
    final nameController = TextEditingController(text: existingHotel?.name ?? '');
    final distController = TextEditingController(text: existingHotel?.distanceFromHaram ?? '');
    final imgController = TextEditingController(text: existingHotel?.image ?? '');
    String selectedCity = existingHotel?.city ?? 'Makkah';
    int selectedRating = existingHotel?.starRating ?? 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppConstants.softCream,
          title: Text(
            existingHotel == null ? 'Add New Partner Hotel' : 'Edit Hotel Details',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Name *',
                    hintText: 'e.g. Pullman Zamzam Makkah',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: selectedCity,
                  decoration: const InputDecoration(labelText: 'City *'),
                  items: const [
                    DropdownMenuItem(value: 'Makkah', child: Text('Makkah Al-Mukarramah')),
                    DropdownMenuItem(value: 'Madinah', child: Text('Madinah Al-Munawwarah')),
                  ],
                  onChanged: (val) => setState(() => selectedCity = val ?? 'Makkah'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: selectedRating,
                  decoration: const InputDecoration(labelText: 'Star Rating *'),
                  items: [3, 4, 5].map((stars) => DropdownMenuItem(value: stars, child: Text('$stars Star Hotel'))).toList(),
                  onChanged: (val) => setState(() => selectedRating = val ?? 5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: distController,
                  decoration: const InputDecoration(
                    labelText: 'Distance from Haram *',
                    hintText: 'e.g. 0 Meters (Direct Haram Gate view)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imgController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Image URL',
                    hintText: 'https://...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && distController.text.isNotEmpty) {
                  final supabase = ref.read(supabaseClientProvider);
                  final isEdit = existingHotel != null;

                  final hotelData = {
                    'name': nameController.text.trim(),
                    'city': selectedCity,
                    'star_rating': selectedRating,
                    'distance_from_haram': distController.text.trim(),
                    'image': imgController.text.trim().isNotEmpty ? imgController.text.trim() : null,
                  };

                  if (isEdit) {
                    if (supabase != null) {
                      try {
                        await supabase.from('hotels').update(hotelData).eq('id', existingHotel.id);
                      } catch (_) {}
                    }
                    final updated = HotelModel(
                      id: existingHotel.id,
                      name: nameController.text.trim(),
                      city: selectedCity,
                      starRating: selectedRating,
                      distanceFromHaram: distController.text.trim(),
                      image: imgController.text.trim().isNotEmpty ? imgController.text.trim() : null,
                    );
                    ref.read(hotelsCrudNotifierProvider.notifier).updateHotel(updated);
                  } else {
                    if (supabase != null) {
                      try {
                        final res = await supabase.from('hotels').insert(hotelData).select().single();
                        final dbHotel = HotelModel.fromJson(res);
                        ref.read(hotelsCrudNotifierProvider.notifier).addHotel(dbHotel);
                      } catch (_) {
                        final newHotel = HotelModel(
                          id: 'hotel_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text.trim(),
                          city: selectedCity,
                          starRating: selectedRating,
                          distanceFromHaram: distController.text.trim(),
                          image: imgController.text.trim().isNotEmpty ? imgController.text.trim() : null,
                        );
                        ref.read(hotelsCrudNotifierProvider.notifier).addHotel(newHotel);
                      }
                    } else {
                      final newHotel = HotelModel(
                        id: 'hotel_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        city: selectedCity,
                        starRating: selectedRating,
                        distanceFromHaram: distController.text.trim(),
                        image: imgController.text.trim().isNotEmpty ? imgController.text.trim() : null,
                      );
                      ref.read(hotelsCrudNotifierProvider.notifier).addHotel(newHotel);
                    }
                  }

                  ref.invalidate(hotelsProvider);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Hotel updated successfully!' : 'New hotel added to database!'),
                      backgroundColor: AppConstants.deepGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGold, foregroundColor: AppConstants.charcoal),
              child: Text(existingHotel == null ? 'SAVE HOTEL' : 'UPDATE HOTEL', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHotel(BuildContext context, WidgetRef ref, HotelModel hotel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.softCream,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
        content: Text('Are you sure you want to delete "${hotel.name}" from hotels?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final supabase = ref.read(supabaseClientProvider);
              if (supabase != null) {
                try {
                  await supabase.from('hotels').delete().eq('id', hotel.id);
                } catch (_) {}
              }
              ref.read(hotelsCrudNotifierProvider.notifier).deleteHotel(hotel.id);
              ref.invalidate(hotelsProvider);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${hotel.name}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('DELETE HOTEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelsAsync = ref.watch(hotelsProvider);
    final isDesktop = ResponsiveUtils.isWebDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hotels & Accommodations Manager',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                          fontSize: isDesktop ? 24 : 20,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Manage Makkah & Madinah 5-Star luxury hotels, distances from Haram, and photos.'),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showHotelDialog(context, ref),
                icon: const Icon(Icons.add, color: AppConstants.charcoal),
                label: const Text('ADD NEW HOTEL', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: AppConstants.charcoal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          hotelsAsync.when(
            data: (hotels) {
              if (hotels.isEmpty) {
                return const Center(child: Text('No hotels found. Click "Add New Hotel" above to get started.'));
              }

              return Container(
                width: double.infinity,
                decoration: AppTheme.glassCardDecoration(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Photo', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Hotel Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Distance from Haram', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: hotels.map((hotel) {
                      return DataRow(cells: [
                        DataCell(
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: hotel.image != null && hotel.image!.isNotEmpty
                                ? Image.network(hotel.image!, width: 50, height: 36, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.hotel))
                                : const Icon(Icons.hotel, color: AppConstants.deepGreen),
                          ),
                        ),
                        DataCell(
                          Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataCell(Text(hotel.city)),
                        DataCell(
                          Row(
                            children: List.generate(
                              hotel.starRating,
                              (i) => const Icon(Icons.star, color: AppConstants.primaryGold, size: 16),
                            ),
                          ),
                        ),
                        DataCell(Text(hotel.distanceFromHaram)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppConstants.deepGreen, size: 20),
                                tooltip: 'Edit Hotel',
                                onPressed: () => _showHotelDialog(context, ref, existingHotel: hotel),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                tooltip: 'Delete Hotel',
                                onPressed: () => _confirmDeleteHotel(context, ref, hotel),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
            error: (err, stack) => const Text('Could not load hotels list'),
          ),
        ],
      ),
    );
  }
}
