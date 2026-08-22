import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../growth/providers/growth_provider.dart';
import '../providers/records_provider.dart';

class RecordDetailScreen extends ConsumerWidget {
  final int childId;

  const RecordDetailScreen({
    super.key,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childDetailProvider(childId));
    final historyAsync = ref.watch(growthHistoryProvider(childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('बच्चे का विवरण (Child Profile)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded),
            tooltip: 'ग्रोथ ट्रैकर',
            onPressed: () => context.push('/more/growth/$childId'),
          ),
        ],
      ),
      body: childAsync.when(
        data: (child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AromiTheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AromiTheme.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AromiTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'उम्र: ${child.displayAge} (${child.genderLabel})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AromiTheme.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'जन्म तिथि: ${child.dob}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AromiTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'पोषण स्थिति (Nutrition)',
                                  style: TextStyle(fontSize: 12, color: AromiTheme.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                NutritionBadge(status: child.nutritionStatus),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'जोखिम स्तर (Risk Level)',
                                  style: TextStyle(fontSize: 12, color: AromiTheme.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                RiskBadge(level: child.riskLevel),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Current Measurements Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'वर्तमान माप (Current Measurements)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AromiTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MeasurementDetailBox(
                              title: 'वजन (Weight)',
                              value: child.currentWeightKg != null ? '${child.currentWeightKg} kg' : 'दर्ज नहीं',
                              icon: Icons.scale_rounded,
                              color: Colors.blue,
                            ),
                            _MeasurementDetailBox(
                              title: 'लंबाई (Height)',
                              value: child.currentHeightCm != null ? '${child.currentHeightCm} cm' : 'दर्ज नहीं',
                              icon: Icons.height_rounded,
                              color: Colors.teal,
                            ),
                            _MeasurementDetailBox(
                              title: 'MUAC',
                              value: child.currentMuacCm != null ? '${child.currentMuacCm} cm' : 'दर्ज नहीं',
                              icon: Icons.straighten_rounded,
                              color: Colors.amber.shade800,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Action Buttons for Child
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/more/growth/${child.id}'),
                        icon: const Icon(Icons.add_chart_rounded),
                        label: const Text('माप दर्ज करें'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/voice'),
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('बोलकर बदलें'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Parent / Guardian Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'अभिभावक विवरण (Family Information)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AromiTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'माता/पिता का नाम:',
                          value: child.parentName ?? 'उपलब्ध नहीं',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'टीकाकरण (Immunisation):',
                          value: child.immunisationUpToDate ? 'अप-टू-डेट ✅' : 'लंबित (Pending) ⚠️',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'PHC रेफरल:',
                          value: child.phcReferred ? 'रेफर किया गया 🏥' : 'नहीं',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Growth History Timeline
                const SectionHeader(title: 'विकास इतिहास (Growth History)'),
                const SizedBox(height: 8),

                historyAsync.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'कोई पिछला विकास माप दर्ज नहीं है।',
                            style: TextStyle(color: AromiTheme.textSecondary),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final rec = history[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AromiTheme.nutritionColor(rec.nutritionStatus).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.show_chart_rounded,
                                color: AromiTheme.nutritionColor(rec.nutritionStatus),
                              ),
                            ),
                            title: Text(
                              'तारीख: ${rec.recordedDate}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('वजन: ${rec.weightKg ?? '-'} kg | MUAC: ${rec.muacCm ?? '-'} cm'),
                                if (rec.aiNotes != null && rec.aiNotes!.isNotEmpty)
                                  Text(
                                    rec.aiNotes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AromiTheme.primaryDark,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: NutritionBadge(status: rec.nutritionStatus),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingStateWidget(message: 'इतिहास लोड हो रहा है...'),
                  error: (err, stack) => const Text('इतिहास लोड करने में असमर्थ'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const LoadingStateWidget(message: 'प्रोफाइल लोड हो रही है...'),
        error: (err, stack) => ErrorStateWidget(
          errorMessage: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(childDetailProvider(childId)),
        ),
      ),
    );
  }
}

class _MeasurementDetailBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MeasurementDetailBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AromiTheme.textPrimary,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AromiTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AromiTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AromiTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
