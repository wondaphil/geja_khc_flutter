import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/auth/presentation/login_page.dart';
import 'home_page.dart';
import 'splash.dart';
import '../features/about/about_page.dart';
import '../features/midibs/presentation/midib_list_page.dart';
import '../features/midibs/presentation/midib_detail_page.dart';
import '../features/midibs/presentation/midib_edit_page.dart';
import '../features/midibs/presentation/midib_new_page.dart';
import '../features/members/presentation/member_list_page.dart';
import '../features/members/presentation/member_detail_page.dart';
import '../features/members/presentation/member_new_page.dart';
import '../features/members/presentation/member_full_detail_page.dart';
import '../features/members/data_entry/member_data_entry_page.dart';
import '../features/members/data_entry/member_basic_info_entry_page.dart';
import '../features/members/data_entry/member_address_info_entry_page.dart';
import '../features/members/data_entry/member_family_info_entry_page.dart';
import '../features/members/data_entry/member_education_and_job_info_entry_page.dart';
import '../features/members/data_entry/member_photo_entry_page.dart';
import '../features/members/data_entry/member_ministry_info_entry_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/reports/presentation/members_count_by_midib_page.dart';
import '../features/reports/presentation/members_count_by_parameters_page.dart';
import '../features/charts/presentation/charts_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/server_address_page.dart';

const kBrandCyan = Color(0xFF00ADEF);

class GejaApp extends StatelessWidget {
  const GejaApp({super.key});

  static const double fontScaleFactor = 1.25;

  TextTheme _getScaledTextTheme() {
    final baseTheme = Typography.blackMountainView;
    return baseTheme.apply(
      fontFamily: 'Ethiopic',
      fontFamilyFallback: const ['Nyala', 'Noto Sans Ethiopic', 'sans-serif'],
      bodyColor: Colors.black,
      displayColor: Colors.black,
    );
  }

  Future<bool> _hasToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kBrandCyan),
      textTheme: _getScaledTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF3FBFE),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(
		  elevation: 1,
		  margin: EdgeInsets.all(12),
		  shape: RoundedRectangleBorder(
			borderRadius: BorderRadius.all(Radius.circular(16)),
		  ),
		),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );

    final router = GoRouter(
	  initialLocation: '/splash',
	  routes: [
		GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
		GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
		GoRoute(path: '/', builder: (context, state) => const HomePage()),
		GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
		GoRoute(path: '/midibs', builder: (context, state) => const MidibListPage()),
		GoRoute(path: '/midibs/new', builder: (context, state) => const MidibNewPage()),
		GoRoute(path: '/reports', builder: (context, state) => const ReportsPage(), routes: [
		  GoRoute(path: 'by-midib', builder: (context, state) => const MembersCountByMidibPage()),
		  GoRoute(path: 'by-parameters', builder: (context, state) => const MemberCountByParametersPage()),
		]),
		GoRoute(path: '/charts', builder: (context, state) => const ChartsPage()),
		GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
		GoRoute(path: '/settings/server', builder: (context, state) => const ServerAddressPage()),
	  ],
	);

    return MaterialApp.router(
      title: 'Geja KHC',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}