import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class ComingSoonCard extends StatelessWidget {
  final String featureName;
  final String phaseBadgeText;
  final IconData? icon;

  const ComingSoonCard({
    super.key,
    required this.featureName,
    this.phaseBadgeText = 'Phase 2',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hindiFont = GoogleFonts.notoSansDevanagari();

    return Opacity(
      opacity: 0.6, // Disabled/greyed-out look
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkBackground, // Even darker than card
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.darkBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                phaseBadgeText,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (icon != null) ...[
              Icon(icon, color: AppColors.darkTextTertiary, size: 40),
              const SizedBox(height: 16),
            ],
            Text(
              featureName,
              style: hindiFont.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'जल्द आ रहा है', // Coming Soon
                style: hindiFont.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
