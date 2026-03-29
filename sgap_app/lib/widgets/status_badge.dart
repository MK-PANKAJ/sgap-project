import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

enum StatusBadgeState { confirmed, pending, disputed }

class StatusBadge extends StatelessWidget {
  final StatusBadgeState state;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.state,
    this.customLabel,
  });

  Color get _backgroundColor {
    switch (state) {
      case StatusBadgeState.confirmed:
        return AppColors.success.withValues(alpha: 0.15);
      case StatusBadgeState.pending:
        return AppColors.warning.withValues(alpha: 0.15);
      case StatusBadgeState.disputed:
        return AppColors.error.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (state) {
      case StatusBadgeState.confirmed:
        return AppColors.success;
      case StatusBadgeState.pending:
        return AppColors.warning;
      case StatusBadgeState.disputed:
        return AppColors.error;
    }
  }

  String get _defaultLabel {
    switch (state) {
      case StatusBadgeState.confirmed:
        return 'सत्यापित'; // Verified/Confirmed
      case StatusBadgeState.pending:
        return 'लंबित'; // Pending
      case StatusBadgeState.disputed:
        return 'विवादित'; // Disputed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        customLabel ?? _defaultLabel,
        style: GoogleFonts.notoSansDevanagari(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
