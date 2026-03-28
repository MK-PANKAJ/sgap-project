import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class TrustScoreGauge extends StatelessWidget {
  final int score;
  final double size;
  final double strokeWidth;

  const TrustScoreGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.strokeWidth = 16,
  });

  Color _getScoreColor(int value) {
    if (value < 500) return AppColors.error; // Red
    if (value < 650) return AppColors.warning; // Yellow
    return AppColors.success; // Green
  }

  String _getScoreLabel(int value) {
    if (value < 500) return 'कमजोर (Weak)';
    if (value < 650) return 'औसत (Fair)';
    return 'उत्कृष्ट (Excellent)';
  }

  @override
  Widget build(BuildContext context) {
    // Clamp score between 300 and 1000
    final clampedScore = score.clamp(300, 1000);
    final color = _getScoreColor(clampedScore);
    
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 300, end: clampedScore),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutCubic,
      builder: (context, animatedScore, child) {
        return SizedBox(
          width: size,
          height: size, // Full size for semicircular needs half height visually, but keeping square for padding
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _GaugePainter(
                  score: animatedScore,
                  minScore: 300,
                  maxScore: 1000,
                  strokeWidth: strokeWidth,
                  color: _getScoreColor(animatedScore),
                  backgroundColor: AppColors.darkBorder,
                ),
              ),
              Positioned(
                bottom: size * 0.25,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$animatedScore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreLabel(animatedScore),
                      style: GoogleFonts.notoSansDevanagari(
                        color: _getScoreColor(animatedScore),
                        fontSize: size * 0.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final int minScore;
  final int maxScore;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.score,
    required this.minScore,
    required this.maxScore,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Semicircular background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Semicircle starts at 180 deg (-pi) and sweeps to 0 deg (pi)
    // Actually, in Flutter arc: startAngle is 0 at 3 o'clock, sweeping clockwise
    // To draw left to right over the top: start at pi, sweep pi
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start from left (180 degrees)
      pi, // Sweep half circle (180 degrees)
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progress = (score - minScore) / (maxScore - minScore);
    final sweepAngle = progress * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, 
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
