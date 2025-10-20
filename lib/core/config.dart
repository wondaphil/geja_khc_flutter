import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kKeyBaseUrl = 'api_base_url';

// Default comes from --dart-define if present, else your current server
const String kDefaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://wondaphil-002-site5.qtempurl.com',
);

class AppConfig extends ChangeNotifier {
  AppConfig._();
  static final AppConfig I = AppConfig._();

  String _baseUrl = kDefaultBaseUrl;
  bool _loaded = false;

  String get baseUrl => _baseUrl;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_kKeyBaseUrl) ?? kDefaultBaseUrl;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = url.trim();
    await prefs.setString(_kKeyBaseUrl, _baseUrl);
    notifyListeners();
  }
}
