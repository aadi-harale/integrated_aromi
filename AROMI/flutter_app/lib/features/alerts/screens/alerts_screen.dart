import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../records/providers/records_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('अलर्ट और कुपोषण (Alerts & Risk)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(childrenListProvider(null)),
          ),
        ],
      ),
      body: childrenAsync.when(
        data: (children) {
          final alertChildren = children
              .where((c) =>
                  c.nutritionStatus.toLowerCase() == 'sam' ||
                  c.nutritionStatus.toLowerCase() == 'mam' ||
                  c.riskLevel.toLowerCase() == 'high' ||
                  c.riskLevel.toLowerCase() == 'critical')
              .toList();

          if (alertChildren.isEmpty) {
            return const EmptyStateWidget(
              title: 'कोई सक्रिय अलर्ट नहीं है 🎉',
              subtitle: 'आपके केंद्र में सभी बच्चों का पोषण सामान्य है',
              icon: Icons.check_circle_outline_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alertChildren.length,
            itemBuilder: (context, index) {
              final child = alertChildren[index];
              final isSam = child.nutritionStatus.toLowerCase() == 'sam';

              return Card(
                color: isSam ? Colors.red.shade50 : Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSam ? AromiTheme.samColor : AromiTheme.mamColor,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSam ? Icons.error_rounded : Icons.warning_rounded,
                                color: isSam ? AromiTheme.samColor : AromiTheme.mamColor,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                child.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AromiTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          NutritionBadge(status: child.nutritionStatus),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'अभिभावक: ${child.parentName ?? '-'}  |  उम्र: ${child.displayAge}',
                        style: const TextStyle(fontSize: 13, color: AromiTheme.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('वजन: ${child.currentWeightKg ?? '-'} kg  '),
                          Text('MUAC: ${child.currentMuacCm ?? '-'} cm'),
                        ],
                      ),
                      if (child.phcReferred) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🏥 PHC रेफरल अनिवार्य है',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AromiTheme.samColor,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => context.push('/records/${child.id}'),
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('विवरण देखें'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/more/growth/${child.id}'),
                            icon: const Icon(Icons.add_chart_rounded, size: 18),
                            label: const Text('माप अपडेट'),
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
        loading: () => const LoadingStateWidget(message: 'अलर्ट लोड हो रहे हैं...'),
        error: (err, stack) => ErrorStateWidget(
          errorMessage: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(childrenListProvider(null)),
        ),
      ),
    );
  }
}
