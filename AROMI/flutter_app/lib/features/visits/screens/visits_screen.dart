import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../records/providers/records_provider.dart';

class VisitsScreen extends ConsumerWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('स्मार्ट गृह भ्रमण (Smart Home Visits)'),
      ),
      body: childrenAsync.when(
        data: (children) {
          // Priority visit queue (SAM/MAM first)
          final visitList = children
              .where((c) => c.nutritionStatus.toLowerCase() != 'normal')
              .toList();

          if (visitList.isEmpty) {
            return const EmptyStateWidget(
              title: 'आज कोई पेंडिंग गृह भ्रमण नहीं है',
              subtitle: 'सभी उच्च-प्राथमिकता वाले बच्चे अपडेटेड हैं',
              icon: Icons.home_work_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: visitList.length,
            itemBuilder: (context, index) {
              final child = visitList[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            child.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          RiskBadge(level: child.riskLevel),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('अभिभावक: ${child.parentName ?? '-'}'),
                      Text('वर्तमान स्थिति: ${child.nutritionStatus.toUpperCase()}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AromiTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'कारण: ${child.nutritionStatus.toUpperCase()} पोषण निगरानी एवं आहार परामर्श',
                          style: const TextStyle(fontSize: 12, color: AromiTheme.primaryDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context.push('/records/${child.id}'),
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: const Text('भ्रमण दर्ज करें (Mark Visited)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingStateWidget(message: 'गृह भ्रमण सूची लोड हो रही है...'),
        error: (err, stack) => ErrorStateWidget(
          errorMessage: err.toString(),
          onRetry: () => ref.invalidate(childrenListProvider(null)),
        ),
      ),
    );
  }
}
