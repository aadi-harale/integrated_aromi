import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/widgets.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String _ageGroup = '3-5';
  int _childCount = 15;
  final String _language = 'hindi';
  bool _isLoading = false;
  Map<String, dynamic>? _generatedPlan;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTodayPlan();
  }

  Future<void> _fetchTodayPlan() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.activityToday);
      if (response is Map<String, dynamic> && response.containsKey('plan')) {
        setState(() {
          _generatedPlan = response['plan'] as Map<String, dynamic>?;
        });
      }
    } catch (_) {}
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.activityGenerate,
        data: {
          'age_group': _ageGroup,
          'child_count': _childCount,
          'language': _language,
        },
      );

      setState(() {
        if (response is Map<String, dynamic> && response.containsKey('plan')) {
          _generatedPlan = response['plan'] as Map<String, dynamic>?;
        }
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
        title: const Text('गतिविधि योजना (Activity Planner)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generator Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI दैनिक गतिविधि जनरेटर',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _ageGroup,
                            decoration: const InputDecoration(labelText: 'आयु वर्ग (Age Group)'),
                            items: const [
                              DropdownMenuItem(value: '3-5', child: Text('3-5 वर्ष')),
                              DropdownMenuItem(value: '0-3', child: Text('0-3 वर्ष')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _ageGroup = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: '$_childCount',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'बच्चों की संख्या'),
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null) _childCount = parsed;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generatePlan,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('आज की योजना बनाएँ (Generate Plan)'),
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

            if (_generatedPlan != null) ...[
              const SizedBox(height: 24),
              SectionHeader(title: _generatedPlan!['session_title']?.toString() ?? 'आज का गतिविधि सत्र'),
              const SizedBox(height: 8),

              if (_generatedPlan!['activities'] is List)
                ...(_generatedPlan!['activities'] as List).map((act) {
                  final activity = act as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                activity['name']?.toString() ?? 'गतिविधि',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AromiTheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${activity['duration_minutes']} मिनट',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AromiTheme.primaryDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'प्रकार: ${activity['type']}',
                            style: const TextStyle(color: AromiTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          if (activity['learning_objective'] != null)
                            Text('🎯 उद्देश्य: ${activity['learning_objective']}'),
                          if (activity['materials_needed'] != null) ...[
                            const SizedBox(height: 6),
                            Text('🎨 आवश्यक सामग्री: ${(activity['materials_needed'] as List).join(', ')}'),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
