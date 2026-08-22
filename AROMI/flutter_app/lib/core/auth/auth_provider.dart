import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'auth_service.dart';

// Singletons / Core Providers
final Provider<SecureStorageService> secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  client.onUnauthenticated = () {
    ref.read(authStateProvider.notifier).logout();
  };
  return client;
});

final Provider<AuthService> authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthService(apiClient, storage);
});

// Auth State
class AuthState {
  final bool isLoading;
  final Worker? worker;
  final String? errorMessage;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.worker,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    Worker? worker,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      worker: worker ?? this.worker,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState(isLoading: true)) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    try {
      final hasToken = await _authService.isLoggedIn();
      if (!hasToken) {
        state = AuthState(isLoading: false, isAuthenticated: false);
        return;
      }

      final worker = await _authService.getMe();
      state = AuthState(
        isLoading: false,
        worker: worker,
        isAuthenticated: true,
      );
    } catch (e) {
      await _authService.logout();
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final worker = await _authService.login(email, password);
      state = AuthState(
        isLoading: false,
        worker: worker,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiError: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(
      isLoading: false,
      worker: null,
      isAuthenticated: false,
    );
  }
}

final StateNotifierProvider<AuthNotifier, AuthState> authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
