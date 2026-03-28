import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

/// Global navigation key — set this from your MaterialApp's navigatorKey
/// so the interceptor can push /login on 401 without requiring BuildContext.
import 'package:flutter/material.dart';
GlobalKey<NavigatorState>? navigatorKey;

/// Dio interceptor that:
/// 1. Reads the JWT from [SecureStorage] and injects it into every request.
/// 2. On 401, clears the token and redirects to the login screen.
/// 3. Logs requests/responses in debug mode with latency tracking.
/// 4. Maps [DioException] status codes → Hindi-friendly error messages.
class ApiInterceptor extends Interceptor {
  ApiInterceptor();

  final SecureStorage _storage = SecureStorage.instance;

  // ─────────────────────────────────────────────────────────
  //  ON REQUEST — inject JWT + debug log
  // ─────────────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read JWT from secure storage before every request
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Timestamp for latency measurement
    options.extra['_requestStartMs'] = DateTime.now().millisecondsSinceEpoch;

    // Debug logging
    if (kDebugMode) {
      debugPrint(
        '┌─ REQUEST ─────────────────────────────────────\n'
        '│ ${options.method}  ${options.baseUrl}${options.path}\n'
        '│ Headers: ${options.headers}\n'
        '│ Query:   ${options.queryParameters}\n'
        '│ Body:    ${options.data}\n'
        '└──────────────────────────────────────────────',
      );
    }

    handler.next(options);
  }

  // ─────────────────────────────────────────────────────────
  //  ON RESPONSE — debug log with latency
  // ─────────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final start = response.requestOptions.extra['_requestStartMs'] as int?;
      final latency = start != null
          ? '${DateTime.now().millisecondsSinceEpoch - start}ms'
          : '?';
      debugPrint(
        '┌─ RESPONSE ────────────────────────────────────\n'
        '│ ${response.requestOptions.method}  '
        '${response.requestOptions.path}  →  ${response.statusCode}  ($latency)\n'
        '│ Data: ${response.data}\n'
        '└──────────────────────────────────────────────',
      );
    }
    handler.next(response);
  }

  // ─────────────────────────────────────────────────────────
  //  ON ERROR — 401 handling + Hindi error messages
  // ─────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      debugPrint(
        '┌─ ERROR ───────────────────────────────────────\n'
        '│ ${err.requestOptions.method}  ${err.requestOptions.path}\n'
        '│ Status: ${err.response?.statusCode}\n'
        '│ Message: ${err.message}\n'
        '│ Data: ${err.response?.data}\n'
        '└──────────────────────────────────────────────',
      );
    }

    final statusCode = err.response?.statusCode;

    switch (statusCode) {
      case 401:
        await _handleUnauthorized(err, handler);
        return;

      case 403:
        handler.reject(_withHindiMessage(
          err,
          'आपको यह कार्य करने की अनुमति नहीं है।',
        ));
        return;

      case 404:
        handler.reject(_withHindiMessage(
          err,
          'अनुरोधित जानकारी नहीं मिली।',
        ));
        return;

      case 422:
        handler.reject(_withHindiMessage(
          err,
          'कृपया सही जानकारी भरें।',
        ));
        return;

      case 429:
        handler.reject(_withHindiMessage(
          err,
          'बहुत अधिक अनुरोध। कृपया कुछ देर बाद प्रयास करें।',
        ));
        return;

      case 500:
      case 502:
      case 503:
        handler.reject(_withHindiMessage(
          err,
          'सर्वर में कोई समस्या है। कृपया बाद में प्रयास करें।',
        ));
        return;

      default:
        // Connection / timeout / unknown errors
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.receiveTimeout) {
          handler.reject(_withHindiMessage(
            err,
            'कनेक्शन का समय समाप्त हो गया। कृपया इंटरनेट जाँचें।',
          ));
          return;
        }
        if (err.type == DioExceptionType.connectionError) {
          handler.reject(_withHindiMessage(
            err,
            'इंटरनेट कनेक्शन नहीं है। कृपया जाँचें और पुनः प्रयास करें।',
          ));
          return;
        }
        handler.next(err);
    }
  }

  // ──── Helpers ────

  /// Clear token + redirect to /login on 401 Unauthorized.
  Future<void> _handleUnauthorized(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Wipe the stored token so the app treats the user as logged-out
    await _storage.clearToken();
    await _storage.clearWorkerProfile();

    // Navigate to login (uses the global navigator key)
    navigatorKey?.currentState?.pushNamedAndRemoveUntil(
      '/phone',
      (route) => false,
    );

    handler.reject(_withHindiMessage(
      err,
      'सत्र समाप्त हो गया है। कृपया दोबारा लॉगिन करें।',
    ));
  }

  /// Wrap a [DioException] with a readable Hindi error message.
  DioException _withHindiMessage(DioException original, String hindiMessage) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: original.type,
      error: hindiMessage,
      message: hindiMessage,
    );
  }
}
