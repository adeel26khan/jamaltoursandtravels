import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/enquiries_provider.dart';

class AdminEnquiriesManager extends ConsumerWidget {
  const AdminEnquiriesManager({super.key});

  void _launchWhatsApp(String phone, String name, String? pkg) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final packageTitle = pkg ?? 'Hajj/Umrah Package';
    final msg = Uri.encodeComponent("Assalamu Alaikum $name! Contacting you from Jamal Tours & Travels regarding $packageTitle.");
    final url = Uri.parse("https://wa.me/91$cleanPhone?text=$msg");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enquiryState = ref.watch(enquiryProvider);
    final enquiryNotifier = ref.read(enquiryProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enquiries Lead Tracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
          ),
          const SizedBox(height: 4),
          const Text('Track pilgrim inquiries, WhatsApp responses, and resolution status.'),
          const SizedBox(height: 28),

          if (enquiryState.enquiries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: AppTheme.glassCardDecoration(),
              child: const Center(child: Text('No inquiries submitted yet.')),
            )
          else
            Container(
              width: double.infinity,
              decoration: AppTheme.glassCardDecoration(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone (+91)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Package Interest', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Travel Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: enquiryState.enquiries.map((e) {
                    return DataRow(cells: [
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            e.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(Text(e.phone)),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            e.packageInterest ?? 'Umrah Package',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(e.preferredDate != null ? '${e.preferredDate!.day}/${e.preferredDate!.month}/${e.preferredDate!.year}' : 'N/A')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: e.status == 'new' ? Colors.redAccent : (e.status == 'contacted' ? Colors.orange : Colors.green),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            e.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                              tooltip: 'Chat on WhatsApp',
                              onPressed: () {
                                _launchWhatsApp(e.phone, e.name, e.packageInterest);
                                enquiryNotifier.updateEnquiryStatus(e.id, 'contacted');
                              },
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'delete') {
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
                                      content: Text('Are you sure you want to delete inquiry lead from "${e.name}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () {
                                            enquiryNotifier.deleteEnquiry(e.id);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Deleted enquiry from ${e.name}')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                          child: const Text('DELETE LEAD', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  enquiryNotifier.updateEnquiryStatus(e.id, val);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'new', child: Text('Mark New')),
                                PopupMenuItem(value: 'contacted', child: Text('Mark Contacted')),
                                PopupMenuItem(value: 'resolved', child: Text('Mark Resolved')),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete Lead', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
