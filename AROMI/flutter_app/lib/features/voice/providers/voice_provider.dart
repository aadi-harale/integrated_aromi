import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../models/models.dart';
import '../../growth/providers/growth_provider.dart';
import '../../records/providers/records_provider.dart';

enum VoiceState {
  idle,
  recording,
  processing,
  result,
  pendingConfirmation,
  saving,
  error,
}

class VoiceAssistantState {
  final VoiceState state;
  final String statusMessage;
  final String? transcribedText;
  final String? responseText;
  final VoiceResponse? lastResponse;
  final PendingVoiceAction? pendingAction;
  final String? errorMessage;
  final bool ttsEnabled;

  VoiceAssistantState({
    this.state = VoiceState.idle,
    this.statusMessage = 'बोलने के लिए माइक बटन दबाएँ',
    this.transcribedText,
    this.responseText,
    this.lastResponse,
    this.pendingAction,
    this.errorMessage,
    this.ttsEnabled = true,
  });

  VoiceAssistantState copyWith({
    VoiceState? state,
    String? statusMessage,
    String? transcribedText,
    String? responseText,
    VoiceResponse? lastResponse,
    PendingVoiceAction? pendingAction,
    String? errorMessage,
    bool? ttsEnabled,
  }) {
    return VoiceAssistantState(
      state: state ?? this.state,
      statusMessage: statusMessage ?? this.statusMessage,
      transcribedText: transcribedText ?? this.transcribedText,
      responseText: responseText ?? this.responseText,
      lastResponse: lastResponse ?? this.lastResponse,
      pendingAction: pendingAction ?? this.pendingAction,
      errorMessage: errorMessage,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceAssistantState> {
  final ApiClient _apiClient;
  final Ref _ref;
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();
  String? _recordedPath;

  VoiceNotifier(this._apiClient, this._ref) : super(VoiceAssistantState()) {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("hi-IN");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  void toggleTts() {
    state = state.copyWith(ttsEnabled: !state.ttsEnabled);
  }

  Future<void> speak(String text) async {
    if (!state.ttsEnabled || text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> startRecording() async {
    try {
      // Request mic permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        state = state.copyWith(
          state: VoiceState.error,
          errorMessage: 'माइक की अनुमति आवश्यक है (Microphone permission required)',
        );
        return;
      }

      final dir = await getTemporaryDirectory();
      _recordedPath = '${dir.path}/aromi_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordedPath!,
      );

      state = state.copyWith(
        state: VoiceState.recording,
        statusMessage: '🎤 सुन रहा हूँ... बोलिए (Listening...)',
        transcribedText: null,
        responseText: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: 'रिकॉर्डिंग शुरू नहीं हो सकी: ${e.toString()}',
      );
    }
  }

  Future<void> stopRecordingAndProcess() async {
    if (state.state != VoiceState.recording) return;

    try {
      final path = await _recorder.stop();
      if (path == null) {
        state = state.copyWith(
          state: VoiceState.idle,
          statusMessage: 'कोई ऑडियो रिकॉर्ड नहीं हुआ',
        );
        return;
      }

      state = state.copyWith(
        state: VoiceState.processing,
        statusMessage: 'AROMI समझ रहा है... (Processing audio with Whisper...)',
      );

      final audioFile = File(path);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found');
      }

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          path,
          filename: 'voice_input.m4a',
        ),
      });

      final response = await _apiClient.postMultipart(
        ApiEndpoints.voiceProcess,
        formData: formData,
      );

      final voiceResponse = VoiceResponse.fromJson(response);

      // Handle extracted entities and pending actions (MUTATION SAFETY)
      PendingVoiceAction? pending;
      if (voiceResponse.detectedIntent == 'log_weight' &&
          voiceResponse.extractedEntities.containsKey('weight_kg')) {
        final weight = (voiceResponse.extractedEntities['weight_kg'] as num).toDouble();
        final childName = voiceResponse.extractedEntities['child_name'] as String?;

        // Suspicious value check (> 100 kg or unreasonable)
        final isSuspicious = weight > 50.0 || weight < 1.0;

        // Try to find matching child from cached records list
        int? matchedChildId;
        double? previousWeight;

        final childrenAsync = _ref.read(childrenListProvider(null));
        childrenAsync.whenData((children) {
          if (childName != null) {
            final match = children.firstWhere(
              (c) => c.name.toLowerCase().contains(childName.toLowerCase()),
              orElse: () => children.first,
            );
            matchedChildId = match.id;
            previousWeight = match.currentWeightKg;
          } else if (children.isNotEmpty) {
            matchedChildId = children.first.id;
            previousWeight = children.first.currentWeightKg;
          }
        });

        pending = PendingVoiceAction(
          actionType: 'growth_record',
          childId: matchedChildId,
          childName: childName ?? 'बच्चा',
          newValues: {'weight_kg': weight},
          currentValues: {'weight_kg': previousWeight},
          transcription: voiceResponse.transcribedText,
          isSuspicious: isSuspicious,
          warningMessage: isSuspicious
              ? '⚠️ असामान्य माप! ($weight kg अत्यधिक प्रतीत होता है)'
              : null,
        );
      }

      state = state.copyWith(
        state: pending != null ? VoiceState.pendingConfirmation : VoiceState.result,
        statusMessage: voiceResponse.agentResponseText,
        transcribedText: voiceResponse.transcribedText,
        responseText: voiceResponse.agentResponseText,
        lastResponse: voiceResponse,
        pendingAction: pending,
      );

      // Speak response using TTS
      speak(voiceResponse.agentResponseText);
    } catch (e) {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: 'आवाज़ प्रोसेस करने में विफल: ${e.toString().replaceFirst('Exception: ', '')}',
        statusMessage: 'त्रुटि हुई',
      );
    }
  }

  void cancelPendingAction() {
    state = state.copyWith(
      state: VoiceState.idle,
      pendingAction: null,
      statusMessage: 'कार्य रद्द कर दिया गया (Action cancelled. DB unchanged)',
    );
  }

  Future<bool> confirmPendingAction() async {
    final pending = state.pendingAction;
    if (pending == null || pending.childId == null) return false;

    state = state.copyWith(
      state: VoiceState.saving,
      statusMessage: 'डेटा सहेजा जा रहा है... (Saving to backend DB...)',
    );

    try {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final recordData = GrowthRecordCreate(
        childId: pending.childId!,
        recordedDate: todayStr,
        weightKg: pending.newValues['weight_kg'] as double?,
        heightCm: pending.newValues['height_cm'] as double?,
        muacCm: pending.newValues['muac_cm'] as double?,
      );

      await _ref.read(growthNotifierProvider.notifier).recordGrowth(recordData);

      state = state.copyWith(
        state: VoiceState.result,
        pendingAction: null,
        statusMessage: '✅ रिकॉर्ड सफलतापूर्वक सहेजा गया! (Successfully saved)',
        responseText: 'माप सहेज लिया गया है।',
      );

      speak('माप सहेज लिया गया है।');
      return true;
    } catch (e) {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: 'सहेजने में विफल: ${e.toString()}',
      );
      return false;
    }
  }

  void resetState() {
    state = VoiceAssistantState();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _tts.stop();
    super.dispose();
  }
}

final voiceNotifierProvider = StateNotifierProvider<VoiceNotifier, VoiceAssistantState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VoiceNotifier(apiClient, ref);
});

final voiceLogsProvider = FutureProvider<List<VoiceLog>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.voiceLogs);
  final List<dynamic> data = response as List<dynamic>;
  return data.map((json) => VoiceLog.fromJson(json)).toList();
});
