import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../errors/api_error.dart';

class ApiConfig {
  static String _overrideBaseUrl = '';

  static void setBaseUrl(String url) {
    _overrideBaseUrl = url.trim();
  }

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    
    // Default base URLs depending on platform
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 is default host loopback for Android emulator
      return 'http://10.0.2.2:8000';
    }
    // iOS / macOS / Windows / Linux
    return 'http://127.0.0.1:8000';
  }
}

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();
  void Function()? onUnauthenticated;

  ApiClient({String? baseUrl, this.onUnauthenticated}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _storage.deleteToken();
            if (onUnauthenticated != null) {
              onUnauthenticated!();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void updateBaseUrl(String newUrl) {
    ApiConfig.setBaseUrl(newUrl);
    _dio.options.baseUrl = ApiConfig.baseUrl;
  }

  ApiError handleDioError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return ApiError.timeout();
      }

      if (error.type == DioExceptionType.connectionError) {
        return ApiError.network(error.message);
      }

      final statusCode = error.response?.statusCode;
      final detail = error.response?.data is Map
          ? (error.response?.data['detail']?.toString())
          : error.message;

      if (statusCode != null) {
        return ApiError.fromStatusCode(statusCode, detail);
      }
      return ApiError.network(error.message);
    }
    if (error is ApiError) {
      return error;
    }
    return ApiError.unknown(error.toString());
  }

  // GET
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw handleDioError(e);
    }
  }

  // POST
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw handleDioError(e);
    }
  }

  // DELETE
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw handleDioError(e);
    }
  }

  // Multipart Upload (e.g. for audio, photo)
  Future<dynamic> postMultipart(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } catch (e) {
      throw handleDioError(e);
    }
  }
}
