import '../../models/models.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/secure_storage.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthService(this._apiClient, this._storage);

  Future<Worker> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final authToken = AuthToken.fromJson(response);
    await _storage.saveToken(authToken.accessToken);

    // Fetch worker profile
    final worker = await getMe();
    return worker;
  }

  Future<Worker> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return Worker.fromJson(response);
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }
}
