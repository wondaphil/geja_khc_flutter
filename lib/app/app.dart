import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../features/reports/presentation/report_by_midib_page.dart';
import '../features/charts/presentation/charts_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/server_address_page.dart';

const kBrandCyan = Color(0xFF00ADEF);

class GejaApp extends StatelessWidget {
  const GejaApp({super.key});
  static const double fontScaleFactor = 1.25;

	// Helper function to create scaled text theme
	TextTheme _getScaledTextTheme() {
	  final baseTheme = Typography.blackMountainView;
	  return TextTheme(
		displayLarge: baseTheme.displayLarge?.copyWith(fontSize: (baseTheme.displayLarge?.fontSize ?? 96) * fontScaleFactor),
		displayMedium: baseTheme.displayMedium?.copyWith(fontSize: (baseTheme.displayMedium?.fontSize ?? 60) * fontScaleFactor),
		displaySmall: baseTheme.displaySmall?.copyWith(fontSize: (baseTheme.displaySmall?.fontSize ?? 48) * fontScaleFactor),
		headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: (baseTheme.headlineLarge?.fontSize ?? 40) * fontScaleFactor),
		headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: (baseTheme.headlineMedium?.fontSize ?? 34) * fontScaleFactor),
		headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * fontScaleFactor),
		titleLarge: baseTheme.titleLarge?.copyWith(fontSize: (baseTheme.titleLarge?.fontSize ?? 20) * fontScaleFactor),
		titleMedium: baseTheme.titleMedium?.copyWith(fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * fontScaleFactor),
		titleSmall: baseTheme.titleSmall?.copyWith(fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * fontScaleFactor),
		bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * fontScaleFactor),
		bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * fontScaleFactor),
		bodySmall: baseTheme.bodySmall?.copyWith(fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * fontScaleFactor),
		labelLarge: baseTheme.labelLarge?.copyWith(fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * fontScaleFactor),
		labelMedium: baseTheme.labelMedium?.copyWith(fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * fontScaleFactor),
		labelSmall: baseTheme.labelSmall?.copyWith(fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * fontScaleFactor),
	  ).apply(fontFamily: 'Ethiopic', fontFamilyFallback: const ['Nyala', 'Noto Sans Ethiopic', 'sans-serif']);
	}
	
  @override
  Widget build(BuildContext context) {
     final theme = ThemeData(
		  useMaterial3: true,
		  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ADEF)),
		  //fontFamily: 'Ethiopic',
		  //fontFamilyFallback: const ['Nyala', 'Noto Sans Ethiopic', 'sans-serif'],
		  textTheme: _getScaledTextTheme(),
		  scaffoldBackgroundColor: const Color(0xFFF3FBFE), // soft cyan-ish background
		  appBarTheme: const AppBarTheme(
			centerTitle: false,
		  ),
		  cardTheme: const CardThemeData( // <-- was CardTheme(...)
			elevation: 1,
			margin: EdgeInsets.all(12),
			shape: RoundedRectangleBorder(
			  borderRadius: BorderRadius.all(Radius.circular(16)),
			),
		  ),
		  inputDecorationTheme: const InputDecorationTheme(
			border: OutlineInputBorder(),
		  ),
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
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(path: '/midibs', builder: (context, state) => const MidibListPage()),
        GoRoute(path: '/midibs/new', builder: (context, state) => const MidibNewPage()),
		GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
        GoRoute(
		  path: '/midibs/:id',
		  builder: (context, state) => MidibDetailPage(
			id: state.pathParameters['id']!,
			name: state.uri.queryParameters['name'] ?? '',
			code: state.uri.queryParameters['code'] ?? '',
			pastor: state.uri.queryParameters['pastor'],
			remark: state.uri.queryParameters['remark'],
		  ),
		),
		GoRoute(
		  path: '/midibs/:id/edit',
		  builder: (context, state) => MidibEditPage(
			id: state.pathParameters['id']!,
			initialName: state.uri.queryParameters['name'] ?? '',
			initialCode: state.uri.queryParameters['code'] ?? '',
			initialPastor: state.uri.queryParameters['pastor'],
			initialRemark: state.uri.queryParameters['remark'],
		  ),
		),
        GoRoute(path: '/members', builder: (context, state) => const MemberListPage()),
        GoRoute(path: '/members/new', builder: (context, state) => const MemberNewPage()),
        GoRoute(
		  path: '/members/:id',
		  builder: (context, state) {
			final id = state.pathParameters['id']!;
			return MemberDetailPage(id: id);
		  },
		),
		GoRoute(
		  path: '/members/:id/full_detail',
		  builder: (context, state) {
			final id = state.pathParameters['id'] ?? '';
			return MemberFullDetailPage(id: id);
		  },
		),
		GoRoute(
		  path: '/member_data_entry',
		  builder: (context, state) => const MemberDataEntryPage(),
		),
		GoRoute(
		  path: '/member_basic_info_entry/:id',
		  builder: (context, state) =>
			  MemberBasicInfoEntryPage(memberId: state.pathParameters['id'] ?? ''),
		),
		GoRoute(
		  path: '/member_address_info_entry/:id',
		  builder: (context, state) =>
			  MemberAddressInfoEntryPage(memberId: state.pathParameters['id'] ?? ''),
		),
		GoRoute(
		  path: '/member_family_info_entry/:id',
		  builder: (context, state) =>
			  MemberFamilyInfoEntryPage(memberId: state.pathParameters['id'] ?? ''),
		),
		GoRoute(
		  path: '/member_education_and_job_info_entry/:id',
		  builder: (context, state) =>
			  MemberEducationAndJobInfoEntryPage(memberId: state.pathParameters['id'] ?? ''),
		),
		GoRoute(
		  path: '/member_photo_entry/:id',
		  builder: (context, state) =>
			  MemberPhotoEntryPage(memberId: state.pathParameters['id'] ?? ''),
		),
		GoRoute(
		  path: '/reports/by-midib',
		  builder: (context, state) => const ReportsByMidibPage(),
		),
		GoRoute(
		  path: '/charts',
		  builder: (context, state) => const ChartsPage(),
		),
		GoRoute(
		  path: '/settings',
		  builder: (context, state) => const SettingsPage(),
		),
		GoRoute(
		  path: '/settings/server',
		  builder: (context, state) => const ServerAddressPage(),
		),
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
