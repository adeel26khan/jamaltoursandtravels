import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../models/package_model.dart';
import '../../providers/packages_provider.dart';
import '../../providers/hotels_provider.dart';
import '../../providers/supabase_provider.dart';

class AdminPackagesManager extends ConsumerWidget {
  const AdminPackagesManager({super.key});

  void _openPackageFormDialog(BuildContext context, {PackageModel? package}) {
    showDialog(
      context: context,
      builder: (context) => _PackageFormDialog(package: package),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
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
                    'Packages CRUD Manager',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                          fontSize: isDesktop ? 24 : 20,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Create, update, and manage Hajj, Umrah, Hotels & Itineraries.'),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _openPackageFormDialog(context),
                icon: const Icon(Icons.add, color: AppConstants.charcoal),
                label: const Text('ADD NEW PACKAGE', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: AppConstants.charcoal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          packagesAsync.when(
            data: (packages) {
              return Container(
                width: double.infinity,
                decoration: AppTheme.glassCardDecoration(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Price (+ 5% GST)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Seats Left', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: packages.map((pkg) {
                      return DataRow(cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              pkg.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(Text(pkg.type.toUpperCase())),
                        DataCell(Text('${pkg.durationDays} Days')),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pkg.originalPriceInr != null)
                                Text(
                                  currencyFormat.format(pkg.originalPriceInr),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                ),
                              Text(currencyFormat.format(pkg.priceInr), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        DataCell(Text('${pkg.availableSeats} Seats')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                tooltip: 'Edit Package, Hotels & Itinerary',
                                onPressed: () => _openPackageFormDialog(context, package: pkg),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                tooltip: 'Delete Package',
                                onPressed: () {
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
                                      content: Text('Are you sure you want to delete "${pkg.title}"?\n\nThis will remove the package permanently from Supabase.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final supabase = ref.read(supabaseClientProvider);
                                            if (supabase != null) {
                                              try {
                                                await supabase.from('package_hotels').delete().eq('package_id', pkg.id);
                                                await supabase.from('package_itineraries').delete().eq('package_id', pkg.id);
                                                await supabase.from('packages').delete().eq('id', pkg.id);
                                              } catch (_) {}
                                            }

                                            ref.read(packagesCrudNotifierProvider.notifier).deletePackage(pkg.id);
                                            ref.invalidate(packagesProvider);
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Deleted ${pkg.title}')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                          child: const Text('DELETE PACKAGE', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
            error: (err, stack) => const Text('Could not load packages list'),
          ),
        ],
      ),
    );
  }
}

class _EditableItineraryItem {
  final TextEditingController dayNumberController;
  final TextEditingController titleController;
  final TextEditingController descController;
  String city;

  _EditableItineraryItem({
    required int dayNumber,
    required String title,
    required String description,
    required this.city,
  })  : dayNumberController = TextEditingController(text: dayNumber.toString()),
        titleController = TextEditingController(text: title),
        descController = TextEditingController(text: description);

  void dispose() {
    dayNumberController.dispose();
    titleController.dispose();
    descController.dispose();
  }
}

class _PackageFormDialog extends ConsumerStatefulWidget {
  final PackageModel? package;
  const _PackageFormDialog({this.package});

  @override
  ConsumerState<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends ConsumerState<_PackageFormDialog> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController originalPriceController;
  late TextEditingController durationController;
  late TextEditingController makkahNightsController;
  late TextEditingController madinahNightsController;
  late TextEditingController seatsController;
  late TextEditingController badgeController;
  late TextEditingController descController;

  String selectedType = 'umrah';
  String? selectedMakkahHotelId;
  String? selectedMadinahHotelId;

  List<_EditableItineraryItem> itineraryItems = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    titleController = TextEditingController(text: p?.title ?? '');
    priceController = TextEditingController(text: p != null ? p.priceInr.toStringAsFixed(0) : '');
    originalPriceController = TextEditingController(text: p?.originalPriceInr != null ? p!.originalPriceInr!.toStringAsFixed(0) : '');
    durationController = TextEditingController(text: (p?.durationDays ?? 15).toString());
    makkahNightsController = TextEditingController(text: (p?.makkahNights ?? 8).toString());
    madinahNightsController = TextEditingController(text: (p?.madinahNights ?? 7).toString());
    seatsController = TextEditingController(text: (p?.availableSeats ?? 30).toString());
    badgeController = TextEditingController(text: p?.badge ?? '');
    descController = TextEditingController(text: p?.description ?? '');
    selectedType = p?.type ?? 'umrah';

    _loadExistingPackageDetails();
  }

  Future<void> _loadExistingPackageDetails() async {
    final p = widget.package;
    if (p != null) {
      final supabase = ref.read(supabaseClientProvider);
      if (supabase != null) {
        try {
          // Fetch Itineraries
          final itinRes = await supabase
              .from('package_itineraries')
              .select('*')
              .eq('package_id', p.id)
              .order('day_number', ascending: true);

          if ((itinRes as List).isNotEmpty) {
            itineraryItems = (itinRes as List).map((json) {
              return _EditableItineraryItem(
                dayNumber: (json['day_number'] as num).toInt(),
                title: json['title'] as String? ?? '',
                description: json['description'] as String? ?? '',
                city: json['city'] as String? ?? 'Makkah',
              );
            }).toList();
          }

          // Fetch Hotel Mappings
          final hotelRes = await supabase
              .from('package_hotels')
              .select('city_type, hotel_id')
              .eq('package_id', p.id);

          for (final row in hotelRes as List) {
            final cityType = row['city_type'] as String?;
            final hId = row['hotel_id'] as String?;
            if (cityType == 'makkah') selectedMakkahHotelId = hId;
            if (cityType == 'madinah') selectedMadinahHotelId = hId;
          }
        } catch (_) {}
      }
    }

    // Default Itinerary Days for New Package if empty
    if (itineraryItems.isEmpty) {
      itineraryItems = [
        _EditableItineraryItem(
          dayNumber: 1,
          city: 'Makkah',
          title: 'Arrival in Jeddah & Transfer to Makkah Mukarramah',
          description: 'Meet representative at Jeddah Airport, luxury AC coach transfer to Makkah hotel, perform Umrah with Scholar.',
        ),
        _EditableItineraryItem(
          dayNumber: 2,
          city: 'Makkah',
          title: 'Rest & Ibadaat in Masjid Al-Haram',
          description: 'Full day reserved for Nawaafil, Quran recitation, and Tawaaf in Masjid Al-Haram.',
        ),
        _EditableItineraryItem(
          dayNumber: 3,
          city: 'Makkah',
          title: 'Historical Makkah Ziyarat Tour',
          description: 'Visit Mina, Muzdalifah, Arafat, Cave Hira (Jabal al-Nour), and Jabal Thawr in AC coach.',
        ),
        _EditableItineraryItem(
          dayNumber: 15,
          city: 'Madinah',
          title: 'Transfer to Madinah Munawwarah & Salaam at Rawdah',
          description: 'Travel to Madinah Munawwarah, check into hotel near Al-Masjid an-Nabawi and present Salam at Rawdah Rasool (SAW).',
        ),
      ];
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    durationController.dispose();
    makkahNightsController.dispose();
    madinahNightsController.dispose();
    seatsController.dispose();
    badgeController.dispose();
    descController.dispose();
    for (final item in itineraryItems) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAllPackageData() async {
    if (titleController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Title and Selling Price')),
      );
      return;
    }

    setState(() => isSaving = true);
    final supabase = ref.read(supabaseClientProvider);
    final isEdit = widget.package != null;
    final packageId = isEdit ? widget.package!.id : 'pkg_${DateTime.now().millisecondsSinceEpoch}';

    final pkgModel = PackageModel(
      id: packageId,
      title: titleController.text.trim(),
      type: selectedType,
      priceInr: double.tryParse(priceController.text.trim()) ?? 100000,
      originalPriceInr: double.tryParse(originalPriceController.text.trim()),
      durationDays: int.tryParse(durationController.text.trim()) ?? 15,
      makkahNights: int.tryParse(makkahNightsController.text.trim()) ?? 8,
      madinahNights: int.tryParse(madinahNightsController.text.trim()) ?? 7,
      badge: badgeController.text.trim().isNotEmpty ? badgeController.text.trim() : null,
      availableSeats: int.tryParse(seatsController.text.trim()) ?? 30,
      description: descController.text.trim().isNotEmpty
          ? descController.text.trim()
          : 'Comprehensive Hajj/Umrah package with 5-Star Haram hotel stay and scholar guidance.',
      images: widget.package?.images.isNotEmpty == true
          ? widget.package!.images
          : ['https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&w=1000&q=80'],
    );

    String finalPackageId = packageId;

    if (supabase != null) {
      try {
        if (isEdit) {
          await supabase.from('packages').update(pkgModel.toSupabaseJson()).eq('id', packageId);
          ref.read(packagesCrudNotifierProvider.notifier).updatePackage(pkgModel);
        } else {
          final res = await supabase.from('packages').insert(pkgModel.toSupabaseJson()).select().single();
          final dbPackage = PackageModel.fromJson(res);
          finalPackageId = dbPackage.id;
          ref.read(packagesCrudNotifierProvider.notifier).addPackage(dbPackage);
        }

        // Save Hotel Mappings in package_hotels table
        await supabase.from('package_hotels').delete().eq('package_id', finalPackageId);
        if (selectedMakkahHotelId != null && selectedMakkahHotelId!.isNotEmpty) {
          await supabase.from('package_hotels').insert({
            'package_id': finalPackageId,
            'hotel_id': selectedMakkahHotelId,
            'city_type': 'makkah',
          });
        }
        if (selectedMadinahHotelId != null && selectedMadinahHotelId!.isNotEmpty) {
          await supabase.from('package_hotels').insert({
            'package_id': finalPackageId,
            'hotel_id': selectedMadinahHotelId,
            'city_type': 'madinah',
          });
        }

        // Save Day-by-Day Itineraries in package_itineraries table
        await supabase.from('package_itineraries').delete().eq('package_id', finalPackageId);
        final itineraryData = itineraryItems.where((it) => it.titleController.text.trim().isNotEmpty).map((it) {
          return {
            'package_id': finalPackageId,
            'day_number': int.tryParse(it.dayNumberController.text.trim()) ?? 1,
            'title': it.titleController.text.trim(),
            'description': it.descController.text.trim(),
            'city': it.city,
          };
        }).toList();

        if (itineraryData.isNotEmpty) {
          await supabase.from('package_itineraries').insert(itineraryData);
        }
      } catch (_) {
        if (!isEdit) {
          ref.read(packagesCrudNotifierProvider.notifier).addPackage(pkgModel);
        }
      }
    } else {
      if (isEdit) {
        ref.read(packagesCrudNotifierProvider.notifier).updatePackage(pkgModel);
      } else {
        ref.read(packagesCrudNotifierProvider.notifier).addPackage(pkgModel);
      }
    }

    ref.invalidate(packagesProvider);
    ref.invalidate(packageItinerariesProvider(finalPackageId));
    ref.invalidate(packageHotelsProvider(finalPackageId));

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Updated package details successfully!' : 'Created new package with Hotels & Itineraries!'),
        backgroundColor: AppConstants.deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.package != null;
    final hotelsAsync = ref.watch(hotelsProvider);

    return AlertDialog(
      backgroundColor: AppConstants.softCream,
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.add_box, color: AppConstants.deepGreen),
          const SizedBox(width: 8),
          Text(
            isEdit ? 'Edit Package, Hotels & Itinerary' : 'Add New Package Listing',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        height: 600,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryGold))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: BASIC PACKAGE INFO
                    _buildSectionHeader('1. BASIC PACKAGE INFORMATION'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Package Title *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'umrah', child: Text('Umrah Package')),
                        DropdownMenuItem(value: 'hajj', child: Text('Hajj Package')),
                        DropdownMenuItem(value: 'air_ticket', child: Text('Air Ticket Service')),
                      ],
                      onChanged: (val) => setState(() => selectedType = val ?? 'umrah'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Selling Price (INR) *'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: originalPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Original Price (Discount Rate)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Duration (Days)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: seatsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Available Seats'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: makkahNightsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Makkah Nights'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: madinahNightsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Madinah Nights'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: badgeController,
                      decoration: const InputDecoration(labelText: 'Badge (e.g., RAMZAN SPECIAL, VIP)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Package Description'),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: HOTEL ACCOMMODATION MAPPING
                    _buildSectionHeader('2. ASSIGNED HOTELS (MAKKAH & MADINAH)'),
                    const SizedBox(height: 12),
                    hotelsAsync.when(
                      data: (hotels) {
                        final makkahHotels = hotels.where((h) => h.city.toLowerCase() == 'makkah').toList();
                        final madinahHotels = hotels.where((h) => h.city.toLowerCase() == 'madinah').toList();

                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedMakkahHotelId,
                              decoration: const InputDecoration(labelText: 'Select Makkah Hotel'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('No Hotel Selected (Default Fallback)')),
                                ...makkahHotels.map((h) => DropdownMenuItem(value: h.id, child: Text('${h.name} (${h.distanceFromHaram})'))),
                              ],
                              onChanged: (val) => setState(() => selectedMakkahHotelId = val),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedMadinahHotelId,
                              decoration: const InputDecoration(labelText: 'Select Madinah Hotel'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('No Hotel Selected (Default Fallback)')),
                                ...madinahHotels.map((h) => DropdownMenuItem(value: h.id, child: Text('${h.name} (${h.distanceFromHaram})'))),
                              ],
                              onChanged: (val) => setState(() => selectedMadinahHotelId = val),
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
                      error: (err, stack) => const Text('Could not load hotels list for mapping'),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3: DAY-BY-DAY ITINERARY BUILDER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('3. DAY-BY-DAY ITINERARY BUILDER'),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              itineraryItems.add(
                                _EditableItineraryItem(
                                  dayNumber: itineraryItems.length + 1,
                                  city: 'Makkah',
                                  title: '',
                                  description: '',
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('ADD DAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryGold,
                            foregroundColor: AppConstants.charcoal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itineraryItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = itineraryItems[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppConstants.borderGold.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: TextField(
                                      controller: item.dayNumberController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Day #'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: item.city,
                                      decoration: const InputDecoration(labelText: 'City'),
                                      items: const [
                                        DropdownMenuItem(value: 'Makkah', child: Text('Makkah')),
                                        DropdownMenuItem(value: 'Madinah', child: Text('Madinah')),
                                        DropdownMenuItem(value: 'Jeddah', child: Text('Jeddah')),
                                        DropdownMenuItem(value: 'Transit', child: Text('Transit')),
                                      ],
                                      onChanged: (val) => setState(() => item.city = val ?? 'Makkah'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        item.dispose();
                                        itineraryItems.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: item.titleController,
                                decoration: const InputDecoration(labelText: 'Day Title (e.g. Arrival & Umrah)'),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: item.descController,
                                maxLines: 2,
                                decoration: const InputDecoration(labelText: 'Activities & Description'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: isSaving ? null : _saveAllPackageData,
          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGold, foregroundColor: AppConstants.charcoal),
          child: isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.charcoal))
              : Text(isEdit ? 'UPDATE PACKAGE & DETAILS' : 'SAVE PACKAGE & DETAILS', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.deepGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: const Border(left: BorderSide(color: AppConstants.primaryGold, width: 4)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConstants.deepGreen),
      ),
    );
  }
}
