/// Normalized error model for API errors.
class ApiError {
  final int? statusCode;
  final String message;
  final String? detail;
  final bool isNetworkError;
  final bool isAuthError;

  ApiError({
    this.statusCode,
    required this.message,
    this.detail,
    this.isNetworkError = false,
    this.isAuthError = false,
  });

  factory ApiError.fromStatusCode(int statusCode, [String? detail]) {
    switch (statusCode) {
      case 401:
        return ApiError(
          statusCode: 401,
          message: 'सत्र समाप्त हो गया। कृपया पुनः लॉगिन करें।',
          detail: detail ?? 'Session expired. Please login again.',
          isAuthError: true,
        );
      case 403:
        return ApiError(
          statusCode: 403,
          message: 'आपको यह कार्य करने की अनुमति नहीं है।',
          detail: detail ?? 'You do not have permission.',
        );
      case 404:
        return ApiError(
          statusCode: 404,
          message: 'अनुरोधित जानकारी नहीं मिली।',
          detail: detail ?? 'Requested resource not found.',
        );
      case 422:
        return ApiError(
          statusCode: 422,
          message: 'अमान्य डेटा। कृपया जाँचें और पुनः प्रयास करें।',
          detail: detail ?? 'Invalid data submitted.',
        );
      case 500:
        return ApiError(
          statusCode: 500,
          message: 'सर्वर में त्रुटि हुई। कृपया बाद में प्रयास करें।',
          detail: detail ?? 'Internal server error.',
        );
      case 503:
        return ApiError(
          statusCode: 503,
          message: 'सेवा उपलब्ध नहीं है।',
          detail: detail ?? 'Service unavailable.',
        );
      default:
        return ApiError(
          statusCode: statusCode,
          message: 'कुछ गलत हो गया (कोड: $statusCode)।',
          detail: detail ?? 'Unexpected error.',
        );
    }
  }

  factory ApiError.network([String? detail]) => ApiError(
        message: 'इंटरनेट कनेक्शन नहीं है। कृपया नेटवर्क जाँचें।',
        detail: detail ?? 'No internet connection.',
        isNetworkError: true,
      );

  factory ApiError.timeout() => ApiError(
        message: 'सर्वर से जवाब नहीं मिला। कृपया पुनः प्रयास करें।',
        detail: 'Request timed out.',
        isNetworkError: true,
      );

  factory ApiError.unknown([String? detail]) => ApiError(
        message: 'एक अज्ञात त्रुटि हुई।',
        detail: detail ?? 'An unknown error occurred.',
      );

  @override
  String toString() => 'ApiError($statusCode): $message';
}
