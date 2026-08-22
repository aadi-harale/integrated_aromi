import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final worker = authState.worker;

    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रोफ़ाइल (Worker Profile)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AromiTheme.primary,
                      child: Text(
                        worker?.name.isNotEmpty == true ? worker!.name[0].toUpperCase() : 'W',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      worker?.name ?? 'आंगनवाड़ी सेविका',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worker?.email ?? '',
                      style: const TextStyle(color: AromiTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AromiTheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AWC Code: ${worker?.centreId ?? 'AWC-PUNE-007'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AromiTheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AWC Centre Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('आंगनवाड़ी केंद्र विवरण', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _ProfileDetailRow(label: 'केंद्र का नाम:', value: worker?.centreName ?? '-'),
                    const Divider(height: 20),
                    _ProfileDetailRow(label: 'गाँव (Village):', value: worker?.village ?? '-'),
                    const Divider(height: 20),
                    _ProfileDetailRow(label: 'जिला (District):', value: worker?.district ?? '-'),
                    const Divider(height: 20),
                    _ProfileDetailRow(label: 'सर्वर URL:', value: ApiConfig.baseUrl),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AromiTheme.error,
                  side: const BorderSide(color: AromiTheme.error),
                ),
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('लॉगआउट करें (Logout)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AromiTheme.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
