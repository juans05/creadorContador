import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _apiBaseUrl = 'https://creadorcontador-production.up.railway.app/api';
const _storage = FlutterSecureStorage();

class ApiClient {
  static final _dio = Dio(BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static Dio get dio => _dio;

  static String? _accessToken;

  static Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    _dio.options.headers['Authorization'] = 'Bearer $access';
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _dio.options.headers.remove('Authorization');
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static String? get accessToken => _accessToken;
}