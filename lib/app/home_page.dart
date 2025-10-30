import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'widgets/app_drawer.dart';
import '../../features/auth/data/token_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const brandCyan = Color(0xFF00ADEF);

  late final AnimationController _ac;
  late final Animation<double> _fadeLogo;
  late final Animation<double> _fadeCards;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeLogo  = CurvedAnimation(parent: _ac, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _fadeCards = CurvedAnimation(parent: _ac, curve: const Interval(0.35, 1.0, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('መነሻ ገጽ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              context.push('/help');
            },
            tooltip: 'እገዛ',
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'about_page') {
                context.push('/about');
                return;
              }

              if (v == 'exit') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ማጥፋት ትፈልጋለህ/ሽ?'),
                    content: const Text('መተግበሪያውን መዘጋት ትፈልጋለህ/ሽ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ተወው')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('ዝጋ')),
                    ],
                  ),
                );
                if (ok == true) {
                  SystemNavigator.pop();
                }
                return;
              }

              if (v == 'logout') {
				  final ok = await showDialog<bool>(
					context: context,
					builder: (ctx) => AlertDialog(
					  title: const Text('ማረጋገጫ'),
					  content: const Text('ከመተግበሪያው መውጣት ትፈልጋለህ?'),
					  actions: [
						TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ተወው')),
						FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ውጣ')),
					  ],
					),
				  );
				  if (ok == true) {
					// clear token and go to login
					await TokenStorage.clear();
					if (context.mounted) context.go('/login');
				  }
				  return;
				}
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'about_page', child: Text('ስለ…')),
              PopupMenuItem(value: 'logout', child: Text('ውጣ')),
              PopupMenuItem(value: 'exit', child: Text('ዝጋ')),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo — fades in first
              FadeTransition(
                opacity: _fadeLogo,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain, // good for wide rectangle logos
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeLogo,
                child: Text(
                  'የአባላት መረጃ አስተዳደር',
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Quick-access cards — fade in after logo
              FadeTransition(
                opacity: _fadeCards,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _QuickCard(
                      color: brandCyan,
                      icon: Icons.groups,
                      emoji: '👥',
                      title: 'ምድቦች',
                      onTap: () => context.push('/midibs'),
                    ),
                    _QuickCard(
                      color: brandCyan,
                      icon: Icons.people,
                      emoji: '👤',
                      title: 'አባላት',
                      onTap: () => context.push('/members'),
                    ),
                    _QuickCard(
                      color: brandCyan,
                      icon: Icons.edit_note,
                      emoji: '📝',
                      title: 'ዝርዝር መረጃ ማስገቢያ',
                      onTap: () => context.push('/member_data_entry'),
                    ),
                    _QuickCard(
                      color: brandCyan,
                      icon: Icons.assignment,
                      emoji: '📋',
                      title: 'ሪፖርት',
                      onTap: () => context.push('/reports'),
                    ),
                    _QuickCard(
                      color: brandCyan,
                      icon: Icons.show_chart,
                      emoji: '📊️',
                      title: 'ቻርት',
                      onTap: () => context.push('/charts'),
                    ),
					_QuickCard(
                      color: brandCyan,
                      icon: Icons.settings, // using Settings for መቼቶች for now
                      emoji: '🗓️',
                      title: 'መቼቶች',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String emoji; // shown lightly in the corner
  final String title;
  final VoidCallback onTap;

  const _QuickCard({
    required this.color,
    required this.icon,
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 150,
        height: 110,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 8, spreadRadius: 1, offset: Offset(0, 3), color: Colors.black12)],
          border: Border.all(color: color.withOpacity(.2)),
        ),
        child: Stack(
          children: [
            // subtle emoji watermark
            Positioned(
              right: 10,
              top: 6,
              child: Opacity(
                opacity: 0.15,
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
            ),
            // content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 28, color: color),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}