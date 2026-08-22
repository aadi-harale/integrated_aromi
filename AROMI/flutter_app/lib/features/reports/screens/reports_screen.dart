import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  MPReport? _report;
  String? _errorMessage;

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.mprGenerate,
        data: {
          'month': _selectedMonth,
          'year': _selectedYear,
        },
      );

      final report = MPReport.fromJson(response);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiError: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MPR रिपोर्ट (Monthly Progress Report)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Year Selector Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'महीना और वर्ष चुनें (Select Month & Year)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedMonth,
                            decoration: const InputDecoration(labelText: 'महीना (Month)'),
                            items: List.generate(12, (index) {
                              final monthNum = index + 1;
                              return DropdownMenuItem<int>(
                                value: monthNum,
                                child: Text('महीना $monthNum'),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedMonth = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedYear,
                            decoration: const InputDecoration(labelText: 'वर्ष (Year)'),
                            items: [2025, 2026, 2027].map((year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text('$year'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedYear = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateReport,
                      icon: const Icon(Icons.assessment_rounded),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('MPR रिपोर्ट तैयार करें (Generate Report)'),
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

            if (_report != null) ...[
              const SizedBox(height: 24),
              SectionHeader(title: 'मासिक रिपोर्ट सारंश: ${_report!.month}/${_report!.year}'),
              const SizedBox(height: 8),

              // Generated Hindi Summary
              if (_report!.summaryHindi != null) ...[
                Card(
                  color: AromiTheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description_outlined, color: AromiTheme.primaryDark),
                            SizedBox(width: 8),
                            Text(
                              'सुपरवाइजर के लिए हिंदी विवरण:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AromiTheme.primaryDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _report!.summaryHindi!,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  MetricCard(
                    title: 'कुल पंजीकृत',
                    value: '${_report!.totalChildren}',
                    icon: Icons.child_care_rounded,
                    color: AromiTheme.secondary,
                  ),
                  MetricCard(
                    title: 'औसत उपस्थिति',
                    value: '${_report!.avgAttendancePct}%',
                    icon: Icons.fact_check_rounded,
                    color: AromiTheme.primary,
                  ),
                  MetricCard(
                    title: 'सामान्य पोषण',
                    value: '${_report!.normalCount}',
                    icon: Icons.check_circle_rounded,
                    color: AromiTheme.normalColor,
                  ),
                  MetricCard(
                    title: 'MAM / SAM कुपोषण',
                    value: '${_report!.mamCount} / ${_report!.samCount}',
                    icon: Icons.warning_rounded,
                    color: AromiTheme.samColor,
                  ),
                  MetricCard(
                    title: 'गृह भ्रमण पूर्ण',
                    value: '${_report!.homeVisitsCompleted}',
                    icon: Icons.home_work_rounded,
                    color: Colors.purple,
                  ),
                  MetricCard(
                    title: 'PHC रेफरल',
                    value: '${_report!.phcReferrals}',
                    icon: Icons.local_hospital_rounded,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
