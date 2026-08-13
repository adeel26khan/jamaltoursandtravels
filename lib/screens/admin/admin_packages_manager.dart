import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../models/package_model.dart';
import '../../providers/packages_provider.dart';
import '../../providers/supabase_provider.dart';

class AdminPackagesManager extends ConsumerWidget {
  const AdminPackagesManager({super.key});

  void _showAddPackageDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: '15');
    final makkahNightsController = TextEditingController(text: '8');
    final madinahNightsController = TextEditingController(text: '7');
    final seatsController = TextEditingController(text: '30');
    final badgeController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'umrah';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.softCream,
        title: const Text('Add New Package Listing', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                onChanged: (val) => selectedType = val ?? 'umrah',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (INR) *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Duration (Days)'),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: seatsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Available Seats'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: badgeController,
                      decoration: const InputDecoration(labelText: 'Badge (e.g. VIP)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Package Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final newPackage = PackageModel(
                  id: 'pkg_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  type: selectedType,
                  priceInr: double.tryParse(priceController.text.trim()) ?? 100000,
                  durationDays: int.tryParse(durationController.text.trim()) ?? 15,
                  makkahNights: int.tryParse(makkahNightsController.text.trim()) ?? 8,
                  madinahNights: int.tryParse(madinahNightsController.text.trim()) ?? 7,
                  badge: badgeController.text.trim().isNotEmpty ? badgeController.text.trim() : null,
                  availableSeats: int.tryParse(seatsController.text.trim()) ?? 30,
                  description: descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : 'Comprehensive Hajj/Umrah package with 5-Star Haram hotel stay and scholar guidance.',
                  images: [
                    'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=1000&q=80',
                  ],
                );

                final supabase = ref.read(supabaseClientProvider);
                if (supabase != null) {
                  try {
                    final res = await supabase.from('packages').insert(newPackage.toSupabaseJson()).select().single();
                    final dbPackage = PackageModel.fromJson(res);
                    ref.read(packagesCrudNotifierProvider.notifier).addPackage(dbPackage);
                  } catch (_) {
                    ref.read(packagesCrudNotifierProvider.notifier).addPackage(newPackage);
                  }
                } else {
                  ref.read(packagesCrudNotifierProvider.notifier).addPackage(newPackage);
                }

                ref.invalidate(packagesProvider);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New package created & saved to database!'), backgroundColor: AppConstants.deepGreen),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGold, foregroundColor: AppConstants.charcoal),
            child: const Text('SAVE PACKAGE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditPackageDialog(BuildContext context, WidgetRef ref, PackageModel package) {
    final titleController = TextEditingController(text: package.title);
    final priceController = TextEditingController(text: package.priceInr.toStringAsFixed(0));
    final durationController = TextEditingController(text: package.durationDays.toString());
    final makkahNightsController = TextEditingController(text: package.makkahNights.toString());
    final madinahNightsController = TextEditingController(text: package.madinahNights.toString());
    final seatsController = TextEditingController(text: package.availableSeats.toString());
    final badgeController = TextEditingController(text: package.badge ?? '');
    final descController = TextEditingController(text: package.description);
    String selectedType = package.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.softCream,
        title: const Text('Edit Package Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                onChanged: (val) => selectedType = val ?? selectedType,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (INR) *'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Duration (Days)'),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: seatsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Available Seats'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: badgeController,
                      decoration: const InputDecoration(labelText: 'Badge (e.g. VIP)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Package Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final updatedPackage = PackageModel(
                  id: package.id,
                  title: titleController.text.trim(),
                  type: selectedType,
                  priceInr: double.tryParse(priceController.text.trim()) ?? package.priceInr,
                  originalPriceInr: package.originalPriceInr,
                  durationDays: int.tryParse(durationController.text.trim()) ?? package.durationDays,
                  makkahNights: int.tryParse(makkahNightsController.text.trim()) ?? package.makkahNights,
                  madinahNights: int.tryParse(madinahNightsController.text.trim()) ?? package.madinahNights,
                  badge: badgeController.text.trim().isNotEmpty ? badgeController.text.trim() : null,
                  maxSeats: package.maxSeats,
                  availableSeats: int.tryParse(seatsController.text.trim()) ?? package.availableSeats,
                  description: descController.text.trim().isNotEmpty ? descController.text.trim() : package.description,
                  images: package.images,
                  isActive: package.isActive,
                  createdAt: package.createdAt,
                );

                final supabase = ref.read(supabaseClientProvider);
                if (supabase != null) {
                  try {
                    await supabase.from('packages').update(updatedPackage.toSupabaseJson()).eq('id', updatedPackage.id);
                  } catch (_) {}
                }

                ref.read(packagesCrudNotifierProvider.notifier).updatePackage(updatedPackage);
                ref.invalidate(packagesProvider);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated ${updatedPackage.title} successfully!'), backgroundColor: AppConstants.deepGreen),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGold, foregroundColor: AppConstants.charcoal),
            child: const Text('UPDATE PACKAGE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
                  const Text('Create, update, and manage Hajj, Umrah & Air Ticket packages.'),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddPackageDialog(context, ref),
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
                        DataCell(Text(currencyFormat.format(pkg.priceInr))),
                        DataCell(Text('${pkg.availableSeats} Seats')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                tooltip: 'Edit Package',
                                onPressed: () => _showEditPackageDialog(context, ref, pkg),
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
