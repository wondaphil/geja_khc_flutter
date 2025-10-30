import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config.dart';

Dio makeDio({BuildContext? context}) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.I.baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  AppConfig.I.addListener(() {
    dio.options.baseUrl = AppConfig.I.baseUrl;
  });

  const storage = FlutterSecureStorage();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      if (e.response?.statusCode == 401 && context != null && context.mounted) {
        await storage.delete(key: 'jwt_token');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('የመጠቀሚያ ጊዜዎ አልፏል፤ እባክዎን እንደገና ይግቡ።')),
        );
        context.go('/login');
      }
      handler.next(e);
    },
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}