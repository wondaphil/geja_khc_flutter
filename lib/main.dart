import 'package:flutter/material.dart';
import 'core/config.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.I.load();
  runApp(const GejaApp());
}