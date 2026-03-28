import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';

/// Welcome screen with confetti animation shown after registration.
///
/// - "स्वागत है, [Name]! 🎉"
/// - Initial trust score: 300 (बन रहा है)
/// - 3 quick tips for improving score
/// - "Dashboard देखो" CTA
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late AnimationController _scoreController;
  late Animation<double> _scoreValue;

  String _userName = '';
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    final random = Random();
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        x: random.nextDouble(),
        y: -random.nextDouble() * 0.5,
        size: 6 + random.nextDouble() * 8,
        speed: 0.3 + random.nextDouble() * 0.7,
        drift: (random.nextDouble() - 0.5) * 0.3,
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        color: [
          AppColors.primary,
          AppColors.primaryLight,
          AppColors.secondary,
          AppColors.success,
          AppColors.warning,
          const Color(0xFFFF6B9D),
          const Color(0xFF9B59B6),
        ][random.nextInt(7)],
      ));
    }

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..forward();

    // Content fade/slide in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    // Score counter animation
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreValue = Tween<double>(begin: 0, end: 300).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _loadNameAndAnimate();
  }

  Future<void> _loadNameAndAnimate() async {
    // Get name from route arguments or storage
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _userName = args;
    } else {
      final profile = await SecureStorage.instance.getWorkerProfile();
      _userName = profile?['name'] as String? ?? 'दोस्त';
    }

    setState(() {});

    // Start content animation after confetti starts
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _scoreController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _contentController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // ── Confetti layer ──
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),

          // ── Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // ── Success icon ──
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.success.withValues(alpha: 0.2),
                              AppColors.success.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.celebration_rounded,
                          size: 52,
                          color: AppColors.success,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Greeting ──
                      Text(
                        'स्वागत है, $_userName! 🎉',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'आपकी प्रोफ़ाइल बन गई है',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // ── Trust Score Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.darkBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'आपका ट्रस्ट स्कोर',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedBuilder(
                              animation: _scoreController,
                              builder: (context, _) {
                                return Text(
                                  '${_scoreValue.value.toInt()}',
                                  style: theme.textTheme.displaySmall
                                      ?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 56,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '🔨 बन रहा है',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'अधिकतम 900',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.darkTextTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Quick tips ──
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '💡 स्कोर बढ़ाने के तरीक़े',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _TipRow(
                        emoji: '🎤',
                        text: 'रोज़ अपनी आय बोलकर रिकॉर्ड करें',
                        points: '+50 अंक',
                      ),
                      _TipRow(
                        emoji: '✅',
                        text: 'नियोक्ता से सत्यापन करवाएँ',
                        points: '+30 अंक',
                      ),
                      _TipRow(
                        emoji: '🪪',
                        text: 'e-Shram कार्ड और आधार लिंक करें',
                        points: '+20 अंक',
                      ),

                      const Spacer(flex: 1),

                      // ── CTA ──
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dashboard देखो',
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tip row ──

class _TipRow extends StatelessWidget {
  final String emoji;
  final String text;
  final String points;

  const _TipRow({
    required this.emoji,
    required this.text,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                points,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CUSTOM CONFETTI ANIMATION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double drift;
  final double rotation;
  final double rotationSpeed;
  final Color color;

  const _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = p.y + progress * p.speed * 1.5;
      if (y > 1.1) continue; // Off-screen

      final x = p.x + sin(progress * pi * 2 * p.speed) * p.drift;
      final alpha = (1 - progress).clamp(0.0, 1.0);
      final angle = p.rotation + progress * p.rotationSpeed;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(angle);

      // Draw small rectangles as confetti pieces
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
