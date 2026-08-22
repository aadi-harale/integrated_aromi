import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../providers/records_provider.dart';

class RecordsListScreen extends ConsumerStatefulWidget {
  const RecordsListScreen({super.key});

  @override
  ConsumerState<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends ConsumerState<RecordsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenListProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('बच्चों के रिकॉर्ड (Children)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'नया बच्चा जोड़ें',
            onPressed: () => context.push('/records/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'बच्चे का नाम या माता-पिता खोजें...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('सभी (All)', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SAM (गंभीर)', 'sam', AromiTheme.samColor),
                      const SizedBox(width: 8),
                      _buildFilterChip('MAM (मध्यम)', 'mam', AromiTheme.mamColor),
                      const SizedBox(width: 8),
                      _buildFilterChip('सामान्य (Normal)', 'normal', AromiTheme.normalColor),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List View
          Expanded(
            child: childrenAsync.when(
              data: (children) {
                // Apply status filter
                final filtered = _statusFilter == 'all'
                    ? children
                    : children
                        .where((c) => c.nutritionStatus.toLowerCase() == _statusFilter)
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    title: 'कोई रिकॉर्ड नहीं मिला',
                    subtitle: _searchQuery.isNotEmpty
                        ? '"$_searchQuery" के लिए कोई बच्चा नहीं मिला'
                        : 'इस श्रेणी में कोई बच्चा नहीं है',
                    icon: Icons.person_search_outlined,
                    buttonLabel: 'नया बच्चा पंजीकृत करें',
                    onButtonPressed: () => context.push('/records/new'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(childrenListProvider);
                  },
                  color: AromiTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final child = filtered[index];
                      return _ChildCard(child: child);
                    },
                  ),
                );
              },
              loading: () => const LoadingStateWidget(message: 'बच्चे लोड हो रहे हैं...'),
              error: (err, stack) => ErrorStateWidget(
                errorMessage: err.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(childrenListProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/records/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('नया बच्चा (Add)'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue, [Color? activeColor]) {
    final isSelected = _statusFilter == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: (activeColor ?? AromiTheme.primary).withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? (activeColor ?? AromiTheme.primaryDark)
            : AromiTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _statusFilter = filterValue;
          });
        }
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;

  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/records/${child.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AromiTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AromiTheme.primaryDark,
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
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AromiTheme.textPrimary,
                          ),
                        ),
                        if (child.parentName != null && child.parentName!.isNotEmpty)
                          Text(
                            'अभिभावक: ${child.parentName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AromiTheme.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'उम्र: ${child.displayAge} | ${child.genderLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AromiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      NutritionBadge(status: child.nutritionStatus),
                      const SizedBox(height: 6),
                      RiskBadge(level: child.riskLevel, showLabel: false),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MeasurementMetric(
                    label: 'वजन (Weight)',
                    value: child.currentWeightKg != null ? '${child.currentWeightKg} kg' : '-',
                  ),
                  _MeasurementMetric(
                    label: 'लंबाई (Height)',
                    value: child.currentHeightCm != null ? '${child.currentHeightCm} cm' : '-',
                  ),
                  _MeasurementMetric(
                    label: 'MUAC',
                    value: child.currentMuacCm != null ? '${child.currentMuacCm} cm' : '-',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MeasurementMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AromiTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AromiTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
