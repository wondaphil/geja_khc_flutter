import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/token_storage.dart'; // ✅ correct relative path

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
    ]).animate(_ctrl);

    _start(); // kick things off
  }

  Future<void> _start() async {
    // Play animation first
    await _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // Then check auth safely
    final token = await TokenStorage.get();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      context.go('/login'); // 🔒 not logged in
    } else {
      context.go('/'); // ✅ logged in
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Center(
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _fade.value,
                child: const Image(
                  image: AssetImage('assets/images/logo_splash.png'),
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}