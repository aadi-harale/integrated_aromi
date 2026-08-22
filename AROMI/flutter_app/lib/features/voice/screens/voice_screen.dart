import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/voice_provider.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceNotifierProvider);
    final notifier = ref.read(voiceNotifierProvider.notifier);

    // Auto-navigate if intent is navigation and validated
    ref.listen<VoiceAssistantState>(voiceNotifierProvider, (previous, next) {
      if (next.state == VoiceState.result && next.lastResponse?.route != null) {
        final route = next.lastResponse!.route!;
        if (route.isNotEmpty) {
          context.go(route);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('आवाज़ सहायक (Voice Assistant)'),
        actions: [
          IconButton(
            icon: Icon(
              voiceState.ttsEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
            tooltip: 'TTS आवाज़ चालू/बंद करें',
            onPressed: () => notifier.toggleTts(),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'आवाज़ इतिहास',
            onPressed: () => _showHistoryBottomSheet(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Top Status Header Card
              Card(
                color: _getStatusBgColor(voiceState.state),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(voiceState.state),
                        color: _getStatusFgColor(voiceState.state),
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          voiceState.statusMessage,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _getStatusFgColor(voiceState.state),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Transcribed Text Card (User Spoke)
              if (voiceState.transcribedText != null) ...[
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'आप बोले (You Said):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AromiTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${voiceState.transcribedText}"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AromiTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Assistant Response Card
              if (voiceState.responseText != null) ...[
                Card(
                  elevation: 2,
                  color: AromiTheme.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AromiTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AromiTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AROMI उत्तर (Response):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AromiTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                voiceState.responseText!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AromiTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Error Banner
              if (voiceState.errorMessage != null) ...[
                Card(
                  color: AromiTheme.error.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AromiTheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            voiceState.errorMessage!,
                            style: const TextStyle(color: AromiTheme.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Pending Confirmation Card (MUTATION SAFETY)
              if (voiceState.state == VoiceState.pendingConfirmation &&
                  voiceState.pendingAction != null) ...[
                _buildConfirmationCard(context, ref, voiceState),
              ],

              const Spacer(),

              // Sample Voice Commands Help Chip Slider
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CommandChip(
                      label: '💡 "Raju Nikam ka weight 17 kilo hai"',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _CommandChip(
                      label: '💡 "Dashboard kholo"',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _CommandChip(
                      label: '💡 "Rahul Sharma ko khojo"',
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _CommandChip(
                      label: '💡 "MAM बच्चे के लिए क्या करें?"',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CENTRAL ANIMATED MIC BUTTON
              GestureDetector(
                onTapDown: (_) {
                  if (voiceState.state == VoiceState.idle ||
                      voiceState.state == VoiceState.result ||
                      voiceState.state == VoiceState.error) {
                    notifier.startRecording();
                  }
                },
                onTapUp: (_) {
                  if (voiceState.state == VoiceState.recording) {
                    notifier.stopRecordingAndProcess();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: voiceState.state == VoiceState.recording ? 110 : 96,
                  height: voiceState.state == VoiceState.recording ? 110 : 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: voiceState.state == VoiceState.recording
                          ? [Colors.red, Colors.redAccent]
                          : [AromiTheme.primary, AromiTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (voiceState.state == VoiceState.recording
                                ? Colors.red
                                : AromiTheme.primary)
                            .withValues(alpha: 0.4),
                        blurRadius: voiceState.state == VoiceState.recording ? 24 : 12,
                        spreadRadius: voiceState.state == VoiceState.recording ? 6 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: voiceState.state == VoiceState.processing ||
                            voiceState.state == VoiceState.saving
                        ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            voiceState.state == VoiceState.recording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                voiceState.state == VoiceState.recording
                  ? 'रोकने और प्रोसेस करने के लिए टैप करें'
                  : 'बोलने के लिए माइक बटन दबाएँ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AromiTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationCard(
    BuildContext context,
    WidgetRef ref,
    VoiceAssistantState voiceState,
  ) {
    final pending = voiceState.pendingAction!;
    final notifier = ref.read(voiceNotifierProvider.notifier);

    return Card(
      elevation: 4,
      color: pending.isSuspicious
          ? Colors.orange.shade50
          : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: pending.isSuspicious ? AromiTheme.warning : AromiTheme.primary,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pending.isSuspicious ? Icons.warning_amber_rounded : Icons.fact_check_rounded,
                  color: pending.isSuspicious ? AromiTheme.warning : AromiTheme.primaryDark,
                ),
                const SizedBox(width: 10),
                Text(
                  pending.isSuspicious ? '⚠️ असामान्य माप (Suspicious Value)' : 'जानकारी की पुष्टि करें (Confirm Action)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: pending.isSuspicious ? AromiTheme.warning : AromiTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('बच्चा: ${pending.childName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (pending.currentValues?['weight_kg'] != null)
              Text('वर्तमान वजन: ${pending.currentValues!['weight_kg']} kg'),
            Text(
              'नया वजन (New): ${pending.newValues['weight_kg']} kg',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AromiTheme.primaryDark),
            ),
            if (pending.warningMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                pending.warningMessage!,
                style: const TextStyle(color: AromiTheme.error, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.cancelPendingAction(),
                    child: const Text('रद्द करें (Cancel)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await notifier.confirmPendingAction();
                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('✅ रिकॉर्ड डेटाबेस में सहेजा गया'),
                            backgroundColor: AromiTheme.success,
                          ),
                        );
                      }
                    },
                    child: const Text('पुष्टि करें (Confirm)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            final logsAsync = ref.watch(voiceLogsProvider);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'हाल के आवाज़ कमाण्ड (Voice Logs History)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: logsAsync.when(
                      data: (logs) {
                        if (logs.isEmpty) {
                          return const Center(child: Text('कोई इतिहास उपलब्ध नहीं है'));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.mic_rounded, color: AromiTheme.primary),
                                title: Text(log.transcribedText ?? 'आवाज़ इनपुट'),
                                subtitle: Text(log.agentResponseText ?? ''),
                                trailing: Text(
                                  log.detectedIntent ?? '',
                                  style: const TextStyle(fontSize: 11, color: AromiTheme.textSecondary),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const LoadingStateWidget(message: 'इतिहास लोड हो रहा है...'),
                      error: (err, stack) => Text('त्रुटि: ${err.toString()}'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusBgColor(VoiceState state) {
    switch (state) {
      case VoiceState.recording:
        return Colors.red.shade50;
      case VoiceState.processing:
      case VoiceState.saving:
        return Colors.blue.shade50;
      case VoiceState.result:
        return Colors.green.shade50;
      case VoiceState.pendingConfirmation:
        return Colors.amber.shade50;
      case VoiceState.error:
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusFgColor(VoiceState state) {
    switch (state) {
      case VoiceState.recording:
      case VoiceState.error:
        return Colors.red.shade800;
      case VoiceState.processing:
      case VoiceState.saving:
        return Colors.blue.shade800;
      case VoiceState.result:
        return Colors.green.shade800;
      case VoiceState.pendingConfirmation:
        return Colors.amber.shade900;
      default:
        return AromiTheme.textPrimary;
    }
  }

  IconData _getStatusIcon(VoiceState state) {
    switch (state) {
      case VoiceState.recording:
        return Icons.mic_rounded;
      case VoiceState.processing:
      case VoiceState.saving:
        return Icons.sync_rounded;
      case VoiceState.result:
        return Icons.check_circle_outline_rounded;
      case VoiceState.pendingConfirmation:
        return Icons.fact_check_rounded;
      case VoiceState.error:
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _CommandChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CommandChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AromiTheme.textPrimary),
      ),
    );
  }
}
