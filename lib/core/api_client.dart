import 'package:dio/dio.dart';
import 'config.dart';

Dio makeDio() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.I.baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  // Live-update baseUrl when user changes it in Settings
  AppConfig.I.addListener(() {
    dio.options.baseUrl = AppConfig.I.baseUrl;
  });

  // Optional logging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: false,
    responseHeader: false,
  ));

  return dio;
}
