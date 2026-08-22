import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../models/models.dart';

final childrenListProvider = FutureProvider.family<List<Child>, String?>((ref, searchQuery) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.children);
  final List<dynamic> data = response as List<dynamic>;
  final children = data.map((json) => Child.fromJson(json)).toList();

  if (searchQuery != null && searchQuery.trim().isNotEmpty) {
    final query = searchQuery.toLowerCase().trim();
    return children.where((child) {
      return child.name.toLowerCase().contains(query) ||
          (child.parentName?.toLowerCase().contains(query) ?? false) ||
          child.id.toString() == query;
    }).toList();
  }

  return children;
});

final childDetailProvider = FutureProvider.family<Child, int>((ref, childId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.child(childId));
  return Child.fromJson(response);
});

class ChildrenNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient _apiClient;
  final Ref _ref;

  ChildrenNotifier(this._apiClient, this._ref) : super(const AsyncValue.data(null));

  Future<Child?> createChild(ChildCreate childData) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.post(
        ApiEndpoints.children,
        data: childData.toJson(),
      );
      final newChild = Child.fromJson(response);
      state = const AsyncValue.data(null);
      _ref.invalidate(childrenListProvider);
      return newChild;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deactivateChild(int childId) async {
    state = const AsyncValue.loading();
    try {
      await _apiClient.delete(ApiEndpoints.child(childId));
      state = const AsyncValue.data(null);
      _ref.invalidate(childrenListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final childrenNotifierProvider = StateNotifierProvider<ChildrenNotifier, AsyncValue<void>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChildrenNotifier(apiClient, ref);
});
