import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../models/models.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.dashboardStats);
  return DashboardStats.fromJson(response);
});
