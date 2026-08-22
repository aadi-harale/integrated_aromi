import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  final _queryController = TextEditingController();
  bool _isLoading = false;
  RAGResponse? _response;
  String? _errorMessage;

  final List<String> _suggestedQuestions = [
    'MAM बच्चे के लिए क्या आहार दें?',
    'MUAC कितना होने पर SAM माना जाता है?',
    'टीकाकरण का सही समय क्या है?',
    'दस्त होने पर ORS और जिंक कैसे दें?',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion([String? question]) async {
    final queryText = question ?? _queryController.text.trim();
    if (queryText.isEmpty) return;

    _queryController.text = queryText;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final responseData = await apiClient.post(
        ApiEndpoints.ragQuery,
        data: {
          'question': queryText,
          'language': 'hindi',
        },
      );

      final ragResponse = RAGResponse.fromJson(responseData);
      setState(() {
        _response = ragResponse;
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
        title: const Text('स्वास्थ्य नियम व दिशानिर्देश (RAG Guidelines)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Input Box
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WHO / ICDS दिशानिर्देशों से प्रश्न पूछें',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _queryController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'उदा. "SAM बच्चे के लिए क्या करें?"',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded, color: AromiTheme.primary),
                          onPressed: () => _askQuestion(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _askQuestion(),
                      icon: const Icon(Icons.search_rounded),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('दिशानिर्देश खोजें (Ask Guidelines)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Suggested Chips
            const Text(
              '💡 अक्सर पूछे जाने वाले सवाल:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AromiTheme.textSecondary),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedQuestions.map((q) {
                return ActionChip(
                  label: Text(q, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AromiTheme.primary.withValues(alpha: 0.08),
                  onPressed: () => _askQuestion(q),
                );
              }).toList(),
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

            if (_response != null) ...[
              const SizedBox(height: 24),
              const SectionHeader(title: 'आधिकारिक उत्तर (Official Answer)'),
              const SizedBox(height: 8),

              Card(
                color: AromiTheme.surface,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AromiTheme.secondary, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _response!.answer,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: AromiTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        '📚 स्रोत संदर्भ (Sources):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AromiTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      ..._response!.sources.map((src) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.bookmark_outline_rounded, size: 14, color: AromiTheme.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  src,
                                  style: const TextStyle(fontSize: 12, color: AromiTheme.secondary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
