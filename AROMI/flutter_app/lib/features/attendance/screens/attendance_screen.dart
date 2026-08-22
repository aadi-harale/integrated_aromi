import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../records/providers/records_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final DateTime _selectedDate = DateTime.now();
  final Map<int, bool> _attendanceMap = {}; // childId -> present
  final Map<int, bool> _mealMap = {};       // childId -> mealGiven
  bool _isSaving = false;

  void _initializeMap(List<Child> children) {
    if (_attendanceMap.isEmpty) {
      for (final c in children) {
        _attendanceMap[c.id] = true;
        _mealMap[c.id] = true;
      }
    }
  }

  Future<void> _submitBulkAttendance(List<Child> children) async {
    setState(() => _isSaving = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final records = children.map((c) {
      return AttendanceRecord(
        childId: c.id,
        date: dateStr,
        present: _attendanceMap[c.id] ?? true,
        mealGiven: _mealMap[c.id] ?? false,
      );
    }).toList();

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiEndpoints.attendanceBulk,
        data: {
          'date': dateStr,
          'records': records.map((r) => r.toJson()).toList(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${records.length} बच्चों की उपस्थिति दर्ज हो गई!'),
          backgroundColor: AromiTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('त्रुटि: ${e.toString()}'),
          backgroundColor: AromiTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenListProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('दैनिक उपस्थिति (Attendance)'),
      ),
      body: childrenAsync.when(
        data: (children) {
          _initializeMap(children);

          final presentCount = _attendanceMap.values.where((v) => v).length;

          return Column(
            children: [
              // Header Card
              Container(
                color: AromiTheme.surface,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'तारीख: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'कुल उपस्थित: $presentCount / ${children.length}',
                          style: const TextStyle(color: AromiTheme.primaryDark, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _submitBulkAttendance(children),
                      icon: const Icon(Icons.save_rounded),
                      label: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('सहेजें (Save)'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Children Attendance List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final isPresent = _attendanceMap[child.id] ?? true;
                    final hasMeal = _mealMap[child.id] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isPresent
                                  ? AromiTheme.success.withValues(alpha: 0.15)
                                  : Colors.grey.shade200,
                              child: Text(
                                child.name[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPresent ? AromiTheme.success : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    'उम्र: ${child.displayAge}',
                                    style: const TextStyle(fontSize: 12, color: AromiTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),

                            // Meal Given Checkbox
                            Column(
                              children: [
                                Checkbox(
                                  value: hasMeal,
                                  activeColor: AromiTheme.primary,
                                  onChanged: isPresent
                                      ? (val) {
                                          setState(() {
                                            _mealMap[child.id] = val ?? false;
                                          });
                                        }
                                      : null,
                                ),
                                const Text('पोषण आहार', style: TextStyle(fontSize: 10)),
                              ],
                            ),

                            const SizedBox(width: 8),

                            // Present / Absent Toggle Button (Large touch target)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _attendanceMap[child.id] = !isPresent;
                                  if (!isPresent == false) {
                                    _mealMap[child.id] = false;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isPresent ? AromiTheme.success : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isPresent ? 'उपस्थित 🟢' : 'अनुपस्थित 🔴',
                                  style: TextStyle(
                                    color: isPresent ? Colors.white : Colors.red.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingStateWidget(message: 'उपस्थिति डेटा लोड हो रहा है...'),
        error: (err, stack) => ErrorStateWidget(
          errorMessage: err.toString(),
          onRetry: () => ref.invalidate(childrenListProvider(null)),
        ),
      ),
    );
  }
}
