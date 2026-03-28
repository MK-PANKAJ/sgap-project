import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hindiFont = GoogleFonts.notoSansDevanagari();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.darkTextTertiary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: hindiFont.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: hindiFont.copyWith(
                color: AppColors.darkTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonLabel != null && onButtonPressed != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel!,
                style: hindiFont.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
