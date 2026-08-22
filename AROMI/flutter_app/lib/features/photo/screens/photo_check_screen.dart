import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/widgets.dart';

class PhotoCheckScreen extends ConsumerStatefulWidget {
  const PhotoCheckScreen({super.key});

  @override
  ConsumerState<PhotoCheckScreen> createState() => _PhotoCheckScreenState();
}

class _PhotoCheckScreenState extends ConsumerState<PhotoCheckScreen> {
  final _childNameController = TextEditingController(text: 'राज कुमार');
  String _demoStatus = 'mam';
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _childNameController.dispose();
    super.dispose();
  }

  Future<void> _runPhotoCheckDemo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final childName = _childNameController.text.trim();
      final response = await apiClient.post(
        '${ApiEndpoints.photoCheckDemo}?child_name=${Uri.encodeComponent(childName)}&status=$_demoStatus',
      );

      setState(() {
        _result = response as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('फोटो से कुपोषण जाँच (Photo Check)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions Card
            Card(
              color: AromiTheme.primary.withValues(alpha: 0.08),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_rounded, color: AromiTheme.primary, size: 32),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI विजुअल कुपोषण स्क्रीनर',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'बच्चे की फोटो से मांसपेशी क्षय व पेट सूजन (MAM/SAM) के संकेत जाँचें',
                            style: TextStyle(fontSize: 12, color: AromiTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Demo Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'जाँच विवरण सेट करें (Demo Checker)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _childNameController,
                      decoration: const InputDecoration(
                        labelText: 'बच्चे का नाम',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _demoStatus,
                      decoration: const InputDecoration(labelText: 'सिमुलेटेड स्थिति (Test Condition)'),
                      items: const [
                        DropdownMenuItem(value: 'mam', child: Text('MAM (मध्यम कुपोषण संकेत)')),
                        DropdownMenuItem(value: 'sam', child: Text('SAM (गंभीर कुपोषण संकेत)')),
                        DropdownMenuItem(value: 'normal', child: Text('Normal (सामान्य पोषण संकेत)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _demoStatus = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _runPhotoCheckDemo,
                      icon: const Icon(Icons.remove_red_eye_rounded),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('फोटो AI जाँच करें (Analyze Photo)'),
                    ),
                  ],
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(_errorMessage!, style: const TextStyle(color: AromiTheme.error)),
                ),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              const SectionHeader(title: 'AI आकलन परिणाम (Visual Assessment)'),
              const SizedBox(height: 8),

              _buildAssessmentResultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentResultCard(Map<String, dynamic> result) {
    final assessment = result['assessment'] as Map<String, dynamic>? ?? {};
    final status = assessment['status']?.toString() ?? 'normal';
    final confidence = assessment['confidence_pct'] ?? 75;
    final explanation = assessment['explanation_hindi']?.toString() ?? '';
    final indicators = (assessment['visual_indicators_hindi'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final actions = (assessment['immediate_actions_hindi'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final dishaNote = result['disha_note']?.toString() ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AromiTheme.nutritionColor(status), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'निष्कर्ष: ${status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AromiTheme.nutritionColor(status),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'विश्वास: $confidence%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              explanation,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (indicators.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('🔍 दिखाई देने वाले संकेत:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              ...indicators.map((ind) => Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text('• $ind', style: const TextStyle(fontSize: 13)),
                  )),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('📋 तुरंत की जाने वाली कार्रवाई:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AromiTheme.primaryDark)),
              const SizedBox(height: 4),
              ...actions.map((act) => Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text('✅ $act', style: const TextStyle(fontSize: 13, color: AromiTheme.primaryDark)),
                  )),
            ],
            if (dishaNote.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dishaNote,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AromiTheme.samColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
