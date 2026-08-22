import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../records/providers/records_provider.dart';
import '../providers/growth_provider.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  final int childId;

  const GrowthScreen({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _muacController = TextEditingController();
  final _dateController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _muacController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submitMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final muac = double.tryParse(_muacController.text.trim());

    if (weight == null && height == null && muac == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कम से कम एक माप (वजन, लंबाई या MUAC) दर्ज करें'),
          backgroundColor: AromiTheme.error,
        ),
      );
      return;
    }

    final recordData = GrowthRecordCreate(
      childId: widget.childId,
      recordedDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      weightKg: weight,
      heightCm: height,
      muacCm: muac,
    );

    final result = await ref.read(growthNotifierProvider.notifier).recordGrowth(recordData);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('माप दर्ज हो गया! स्थिति: ${result.nutritionStatus.toUpperCase()}'),
          backgroundColor: AromiTheme.nutritionColor(result.nutritionStatus),
        ),
      );

      _weightController.clear();
      _heightController.clear();
      _muacController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childDetailProvider(widget.childId));
    final historyAsync = ref.watch(growthHistoryProvider(widget.childId));
    final growthState = ref.watch(growthNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ग्रोथ ट्रैकर (Growth Tracker)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child Overview Header
            childAsync.when(
              data: (child) => Card(
                color: AromiTheme.primary.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AromiTheme.primary,
                        child: Text(
                          child.name[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text('उम्र: ${child.displayAge} | वर्तमान: ${child.currentWeightKg ?? '-'} kg'),
                          ],
                        ),
                      ),
                      NutritionBadge(status: child.nutritionStatus),
                    ],
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),
            const SectionHeader(title: 'नया माप दर्ज करें (New Measurement)'),
            const SizedBox(height: 8),

            // Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Date
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'माप की तारीख (Date)',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Weight
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'वजन (Weight in kg)',
                          prefixIcon: Icon(Icons.scale_rounded),
                          suffixText: 'kg',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Height
                      TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'लंबाई (Height in cm)',
                          prefixIcon: Icon(Icons.height_rounded),
                          suffixText: 'cm',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // MUAC
                      TextFormField(
                        controller: _muacController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'MUAC (in cm)',
                          prefixIcon: Icon(Icons.straighten_rounded),
                          hintText: '< 11.5 cm = SAM, 11.5-12.5 = MAM',
                          suffixText: 'cm',
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: growthState.isLoading ? null : _submitMeasurement,
                        child: growthState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('माप सहेजें (Save Measurement)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const SectionHeader(title: 'माप इतिहास (Measurement History)'),
            const SizedBox(height: 8),

            // History List
            historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'कोई माप दर्ज नहीं है',
                    icon: Icons.show_chart_rounded,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final rec = history[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rec.recordedDate,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                NutritionBadge(status: rec.nutritionStatus),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('वजन: ${rec.weightKg ?? '-'} kg  |  '),
                                Text('लंबाई: ${rec.heightCm ?? '-'} cm  |  '),
                                Text('MUAC: ${rec.muacCm ?? '-'} cm'),
                              ],
                            ),
                            if (rec.aiNotes != null && rec.aiNotes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '🤖 ${rec.aiNotes}',
                                  style: const TextStyle(fontSize: 12, color: AromiTheme.primaryDark),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingStateWidget(message: 'इतिहास लोड हो रहा है...'),
              error: (err, stack) => Text('त्रुटि: ${err.toString()}'),
            ),
          ],
        ),
      ),
    );
  }
}
