import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/responsive_utils.dart';
import '../../models/testimonial_model.dart';
import '../../providers/packages_provider.dart';

class AdminTestimonialsManager extends ConsumerWidget {
  const AdminTestimonialsManager({super.key});

  void _showAddTestimonialDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final cityController = TextEditingController(text: 'Mumbai');
    final commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppConstants.softCream,
            title: const Text('Add Pilgrim Review Testimonial', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.deepGreen)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Pilgrim Name *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City / Location'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating: '),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: AppConstants.primaryGold,
                            ),
                            onPressed: () => setState(() => rating = index + 1),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Testimonial Comment *'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && commentController.text.isNotEmpty) {
                    final t = TestimonialModel(
                      id: 't_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      city: cityController.text.trim(),
                      rating: rating,
                      comment: commentController.text.trim(),
                    );

                    ref.read(testimonialsCrudNotifierProvider.notifier).addTestimonial(t);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Testimonial added!'), backgroundColor: AppConstants.deepGreen),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGold, foregroundColor: AppConstants.charcoal),
                child: const Text('SAVE TESTIMONIAL', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testimonialsAsync = ref.watch(testimonialsProvider);
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
                    'Pilgrim Testimonials Editor',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                          fontSize: isDesktop ? 24 : 20,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Manage pilgrim reviews displayed on the website homepage.'),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTestimonialDialog(context, ref),
                icon: const Icon(Icons.add, color: AppConstants.charcoal),
                label: const Text('ADD TESTIMONIAL', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: AppConstants.charcoal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          testimonialsAsync.when(
            data: (testimonials) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: testimonials.length,
                itemBuilder: (context, index) {
                  final t = testimonials[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCardDecoration(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppConstants.deepGreen,
                          child: Icon(Icons.format_quote, color: AppConstants.primaryGold),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.deepGreen),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          t.rating,
                                          (_) => const Icon(Icons.star, color: AppConstants.primaryGold, size: 16),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
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
                                              content: Text('Are you sure you want to delete testimonial review by "${t.name}"?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    ref.read(testimonialsCrudNotifierProvider.notifier).deleteTestimonial(t.id);
                                                    ref.invalidate(testimonialsProvider);
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Removed review by ${t.name}')),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                                  child: const Text('DELETE REVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text('${t.city} • Umrah Pilgrim', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text(t.comment, style: const TextStyle(fontSize: 14, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const CircularProgressIndicator(color: AppConstants.primaryGold),
            error: (err, stack) => const Text('Could not load testimonials'),
          ),
        ],
      ),
    );
  }
}
