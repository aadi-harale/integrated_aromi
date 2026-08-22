import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around flutter_secure_storage for token management.
class SecureStorageService {
  static const _tokenKey = 'aromi_access_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Store the JWT access token.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve the stored JWT access token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the stored token (logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if a token exists.
  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
