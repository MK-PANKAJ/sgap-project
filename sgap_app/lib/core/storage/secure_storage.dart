import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value store for auth tokens, worker profiles, and preferences.
///
/// Uses [FlutterSecureStorage] under the hood with Android encrypted
/// shared-prefs enabled for maximum security on low-end devices.
class SecureStorage {
  SecureStorage._internal();
  static final SecureStorage _instance = SecureStorage._internal();
  static SecureStorage get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ──── Storage Keys ────

  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyWorkerProfile = 'worker_profile';
  static const String _keyLanguage = 'language';
  static const String _keyUserId = 'user_id';
  static const String _keyOnboarded = 'onboarded';
  static const String _keyPhone = 'phone';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  AUTH TOKEN
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Persist the JWT access token.
  Future<void> saveToken(String token) =>
      _storage.write(key: _keyAuthToken, value: token);

  /// Read the stored JWT. Returns `null` if absent.
  Future<String?> getToken() => _storage.read(key: _keyAuthToken);

  /// Remove the JWT (e.g. on logout or 401).
  Future<void> clearToken() => _storage.delete(key: _keyAuthToken);

  /// Quick check — is the user probably authenticated?
  Future<bool> hasToken() async => (await getToken()) != null;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  REFRESH TOKEN
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> clearRefreshToken() => _storage.delete(key: _keyRefreshToken);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  WORKER PROFILE (stored as JSON string)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Persist the full worker profile map as a JSON string.
  Future<void> saveWorkerProfile(Map<String, dynamic> profile) =>
      _storage.write(key: _keyWorkerProfile, value: jsonEncode(profile));

  /// Read & decode the stored worker profile. Returns `null` if absent.
  Future<Map<String, dynamic>?> getWorkerProfile() async {
    final raw = await _storage.read(key: _keyWorkerProfile);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Remove the cached worker profile.
  Future<void> clearWorkerProfile() =>
      _storage.delete(key: _keyWorkerProfile);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  LANGUAGE PREFERENCE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Save the user's preferred language code (e.g. 'hi', 'en').
  Future<void> saveLanguage(String langCode) =>
      _storage.write(key: _keyLanguage, value: langCode);

  /// Read the stored language code.
  Future<String?> getLanguage() => _storage.read(key: _keyLanguage);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  USER ID
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  ONBOARDING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> setOnboarded() =>
      _storage.write(key: _keyOnboarded, value: 'true');

  Future<bool> isOnboarded() async =>
      (await _storage.read(key: _keyOnboarded)) == 'true';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PHONE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> savePhone(String phone) =>
      _storage.write(key: _keyPhone, value: phone);

  Future<String?> getPhone() => _storage.read(key: _keyPhone);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  UTILITY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Wipe everything — full logout.
  Future<void> clearAll() => _storage.deleteAll();

  /// Generic read for future extension.
  Future<String?> read(String key) => _storage.read(key: key);

  /// Generic write for future extension.
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
