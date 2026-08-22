import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final worker = authState.worker;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'नमस्ते, ${worker?.name ?? 'सेविका'} 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (worker?.centreName != null)
              Text(
                '${worker!.centreName} (${worker.centreId})',
                style: const TextStyle(
                  fontSize: 12,
                  color: AromiTheme.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'ताज़ा करें (Refresh)',
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/more/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        color: AromiTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voice Assistant Primary Hero Card
              Card(
                color: AromiTheme.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () => context.go('/voice'),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'बोलकर काम करें 🎤',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'वजन दर्ज करें, नाम खोजें या सवाल पूछें',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Metrics Grid
              const SectionHeader(title: 'आज की स्थिति (Today\'s Status)'),
              const SizedBox(height: 8),

              statsAsync.when(
                data: (stats) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      MetricCard(
                        title: 'कुल बच्चे (Children)',
                        value: '${stats.totalChildren}',
                        subtitle: 'केंद्र में पंजीकृत',
                        icon: Icons.child_care_rounded,
                        color: AromiTheme.secondary,
                        onTap: () => context.go('/records'),
                      ),
                      MetricCard(
                        title: 'आज उपस्थिति (Present)',
                        value: '${stats.presentToday}',
                        subtitle: 'उपस्थित बच्चे',
                        icon: Icons.fact_check_outlined,
                        color: AromiTheme.primary,
                        onTap: () => context.push('/more/attendance'),
                      ),
                      MetricCard(
                        title: 'MAM (मध्यम कुपोषण)',
                        value: '${stats.mamCount}',
                        subtitle: 'विशेष पोषण सहायता',
                        icon: Icons.warning_amber_rounded,
                        color: AromiTheme.mamColor,
                        onTap: () => context.go('/alerts'),
                      ),
                      MetricCard(
                        title: 'SAM (गंभीर कुपोषण)',
                        value: '${stats.samCount}',
                        subtitle: 'तत्काल रेफरल आवश्यक',
                        icon: Icons.error_outline_rounded,
                        color: AromiTheme.samColor,
                        onTap: () => context.go('/alerts'),
                      ),
                      MetricCard(
                        title: 'गृह भ्रमण (Visits Due)',
                        value: '${stats.visitsDueToday}',
                        subtitle: 'आज जाने योग्य',
                        icon: Icons.home_work_outlined,
                        color: Colors.purple,
                        onTap: () => context.push('/more/visits'),
                      ),
                      MetricCard(
                        title: 'समय बचत (Hours Saved)',
                        value: '${stats.workerHoursSaved}h',
                        subtitle: 'AI सहायता से',
                        icon: Icons.bolt_rounded,
                        color: Colors.teal,
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: LoadingStateWidget(message: 'डेटा लोड हो रहा है...'),
                ),
                error: (err, stack) => ErrorStateWidget(
                  errorMessage: err.toString().replaceFirst('Exception: ', ''),
                  onRetry: () => ref.invalidate(dashboardStatsProvider),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const SectionHeader(title: 'त्वरित कार्य (Quick Actions)'),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'नया बच्चा',
                    color: AromiTheme.secondary,
                    onTap: () => context.push('/records/new'),
                  ),
                  _QuickActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'फोटो जाँच',
                    color: Colors.pink,
                    onTap: () => context.push('/more/photo'),
                  ),
                  _QuickActionButton(
                    icon: Icons.event_note_rounded,
                    label: 'गतिविधि',
                    color: Colors.orange,
                    onTap: () => context.push('/more/activity'),
                  ),
                  _QuickActionButton(
                    icon: Icons.description_outlined,
                    label: 'MPR रिपोर्ट',
                    color: Colors.indigo,
                    onTap: () => context.push('/more/reports'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Attention Banner if MAM/SAM exist
              statsAsync.maybeWhen(
                data: (stats) {
                  if (stats.samCount > 0 || stats.mamCount > 0) {
                    return Card(
                      color: AromiTheme.samColor.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AromiTheme.samColor.withValues(alpha: 0.4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AromiTheme.samColor,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${stats.samCount} SAM और ${stats.mamCount} MAM बच्चे',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AromiTheme.samColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'पोषण फॉलो-अप और गृह भ्रमण सुनिश्चित करें',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AromiTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/alerts'),
                              child: const Text('देखें'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AromiTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
