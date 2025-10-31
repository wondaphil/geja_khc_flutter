import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/token_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _fadeOutCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Logo fade/scale animation
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Page fade-out controller
    _fadeOutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

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

    // Fade-out effect
    _fadeOut = CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeOut);

    _playSequence();
  }

  Future<void> _playSequence() async {
    await _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));

    // Start fade-out before navigating
    await _fadeOutCtrl.forward();

    final token = await TokenStorage.get();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      context.go('/login');
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fadeOutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeOutCtrl,
      builder: (context, _) {
        // Fade to white instead of black
        return Container(
          color: Colors.white.withOpacity(_fadeOut.value),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Center(
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Opacity(
                      opacity: _fadeIn.value,
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
          ),
        );
      },
    );
  }
}