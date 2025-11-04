import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Dio makeDio() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.I.baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  // 🔄 Live-update baseUrl if changed in settings
  AppConfig.I.addListener(() {
    dio.options.baseUrl = AppConfig.I.baseUrl;
  });

  // 🟦 Attach interceptors
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      // 🟥 If token expired or unauthorized
      if (e.response?.statusCode == 401) {
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'jwt_token');
        await storage.delete(key: 'username');

        // Force logout — redirect to login page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        });
      }
      return handler.next(e);
    },
  ));

  // Optional logging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: false,
    requestHeader: false,
    responseHeader: false,
  ));

  return dio;
}