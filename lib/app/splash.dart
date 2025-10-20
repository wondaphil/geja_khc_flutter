import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      duration: const Duration(milliseconds: 2500),
    );

    // Fade from 0 → 1 across the whole duration
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Scale: 0.2 → 1.15 (overshoot) → 1.0 (settle)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70, // first 70% of the time
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30, // final 30%
      ),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(() {
      if (mounted) context.go('/');
    });
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
                  width: 140, // tweak if you want a larger final size
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