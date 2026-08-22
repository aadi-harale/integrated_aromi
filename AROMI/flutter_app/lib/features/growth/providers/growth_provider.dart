import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../models/models.dart';
import '../../records/providers/records_provider.dart';

final growthHistoryProvider = FutureProvider.family<List<GrowthRecord>, int>((ref, childId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.growthHistory(childId));
  final List<dynamic> data = response as List<dynamic>;
  return data.map((json) => GrowthRecord.fromJson(json)).toList();
});

class GrowthNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient _apiClient;
  final Ref _ref;

  GrowthNotifier(this._apiClient, this._ref) : super(const AsyncValue.data(null));

  Future<GrowthRecord?> recordGrowth(GrowthRecordCreate data) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.post(
        ApiEndpoints.growthRecord,
        data: data.toJson(),
      );
      final record = GrowthRecord.fromJson(response);
      state = const AsyncValue.data(null);
      _ref.invalidate(growthHistoryProvider(data.childId));
      _ref.invalidate(childrenListProvider(null));
      _ref.invalidate(childDetailProvider(data.childId));
      return record;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final growthNotifierProvider = StateNotifierProvider<GrowthNotifier, AsyncValue<void>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GrowthNotifier(apiClient, ref);
});
