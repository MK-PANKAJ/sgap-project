import 'package:dio/dio.dart';
import 'api_interceptor.dart';

/// Base URL for the S-GAP backend.
/// 10.0.2.2 maps to the host machine's localhost when running in
/// the Android emulator.
const String _kBaseUrl = 'https://sgap-project.onrender.com/api/v1/';

/// Centralized Dio-based HTTP client (singleton).
///
/// All network traffic flows through this class to ensure consistent
/// base-URL, timeouts, interceptors, and error handling.
///
/// Usage:
/// ```dart
/// ApiClient.instance.init();
/// final response = await ApiClient.instance.get('/workers/me');
/// ```
class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  bool _initialised = false;

  /// Initialise the HTTP client. Call once during app bootstrap.
  ///
  /// - [baseUrl] defaults to the Android-emulator localhost proxy.
  /// - [connectTimeout] and [receiveTimeout] both default to 30 s.
  void init({
    String baseUrl = _kBaseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    if (_initialised) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors — order matters:
    //   1. Auth + error mapping (ApiInterceptor)
    _dio.interceptors.add(ApiInterceptor());

    _initialised = true;
  }

  /// Raw Dio instance for advanced use-cases (e.g. multipart uploads).
  Dio get dio {
    assert(_initialised, 'ApiClient.init() must be called before use.');
    return _dio;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  CONVENIENCE HTTP METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// HTTP GET with optional query parameters.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  /// HTTP POST with an optional request body.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  /// HTTP PUT with an optional request body.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  /// HTTP DELETE with an optional body.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  ERROR HELPER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Convert any [DioException] into a user-readable Hindi string.
  /// Already handled in [ApiInterceptor] but exposed here for catch blocks.
  static String readableError(DioException e) {
    // If the interceptor already set a Hindi message, use it.
    if (e.error is String && (e.error as String).isNotEmpty) {
      return e.error as String;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'कनेक्शन का समय समाप्त हो गया। कृपया इंटरनेट जाँचें।';
      case DioExceptionType.connectionError:
        return 'इंटरनेट कनेक्शन नहीं है। कृपया जाँचें और पुनः प्रयास करें।';
      case DioExceptionType.badResponse:
        return 'सर्वर से गलत उत्तर आया (${e.response?.statusCode})।';
      case DioExceptionType.cancel:
        return 'अनुरोध रद्द कर दिया गया।';
      default:
        return 'कुछ गड़बड़ हो गई। कृपया पुनः प्रयास करें।';
    }
  }
}
