import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';

/// Animated splash screen with S-GAP branding.
///
/// - Orange circular logo with wallet icon
/// - "आपका Digital मुनीम" tagline
/// - Animated loading dots
/// - Auto-navigates after 2.5 s → Dashboard (if token) or Language
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  late AnimationController _taglineController;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Tagline animation — starts after logo
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _startAnimations();
    _navigateAfterDelay();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _taglineController.forward();
    _dotsController.repeat();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final hasToken = await SecureStorage.instance.hasToken();
    if (!mounted) return;

    if (hasToken) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/language');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Orange circular logo ──
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Brand name ──
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: child,
                );
              },
              child: Text(
                'S-GAP',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      fontSize: 42,
                    ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tagline in Hindi ──
            AnimatedBuilder(
              animation: _taglineController,
              builder: (context, child) {
                return SlideTransition(
                  position: _taglineSlide,
                  child: Opacity(
                    opacity: _taglineFade.value,
                    child: child,
                  ),
                );
              },
              child: Text(
                'आपका Digital मुनीम',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
              ),
            ),

            const SizedBox(height: 56),

            // ── Animated loading dots ──
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    // Each dot animates with a phase offset
                    final delay = index * 0.3;
                    final progress =
                        ((_dotsController.value + delay) % 1.0);
                    final opacity = (1 - (progress - 0.5).abs() * 2)
                        .clamp(0.2, 1.0);
                    final scale = 0.6 + 0.4 * opacity;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary
                                .withValues(alpha: opacity),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
