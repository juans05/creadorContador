import 'package:dio/dio.dart';

const _apiBaseUrl = 'https://creadorcontador-production.up.railway.app/api';

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
  }

  static void clearTokens() {
    _accessToken = null;
    _dio.options.headers.remove('Authorization');
  }

  static String? get accessToken => _accessToken;
}