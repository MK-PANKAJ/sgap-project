import 'package:flutter/material.dart';

/// S-GAP Brand Color Palette
/// Designed for accessibility and readability for informal/gig workers.
class AppColors {
  AppColors._();

  // ──── Brand Primary (Orange) ────
  static const Color primary = Color(0xFFF97316);
  static const Color primaryLight = Color(0xFFFB923C);
  static const Color primaryDark = Color(0xFFEA580C);
  static const Color primarySurface = Color(0xFFFFF7ED);

  // ──── Accent / Secondary (Teal) ────
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryDark = Color(0xFF0D9488);

  // ──── Backgrounds ────
  static const Color darkBackground = Color(0xFF0A0C10);
  static const Color darkSurface = Color(0xFF141820);
  static const Color darkCard = Color(0xFF1C2028);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ──── Text Colors ────
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // ──── Semantic Colors ────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ──── Trust Score Gradient Colors ────
  static const Color trustLow = Color(0xFFEF4444);
  static const Color trustMedium = Color(0xFFF59E0B);
  static const Color trustHigh = Color(0xFF22C55E);
  static const Color trustExcellent = Color(0xFF14B8A6);

  // ──── Border & Divider ────
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFF334155);

  // ──── Shimmer Colors ────
  static const Color shimmerBase = Color(0xFF1E293B);
  static const Color shimmerHighlight = Color(0xFF334155);
  static const Color shimmerBaseLt = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLt = Color(0xFFF1F5F9);

  /// Returns gradient colors for a given trust score (0-100).
  static Color trustScoreColor(int score) {
    if (score < 30) return trustLow;
    if (score < 55) return trustMedium;
    if (score < 80) return trustHigh;
    return trustExcellent;
  }

  /// Returns a linear gradient for trust score gauge backgrounds.
  static LinearGradient get trustScoreGradient => const LinearGradient(
        colors: [trustLow, trustMedium, trustHigh, trustExcellent],
        stops: [0.0, 0.35, 0.65, 1.0],
      );

  /// Primary brand gradient for headers, CTAs, etc.
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryDark],
      );

  /// Dark card gradient for glassmorphism.
  static LinearGradient get darkCardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          darkCard.withOpacity(0.8),
          darkCard.withOpacity(0.4),
        ],
      );
}
