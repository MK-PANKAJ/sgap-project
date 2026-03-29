import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class SgapTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const SgapTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hindiFont = GoogleFonts.notoSansDevanagari();

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      style: hindiFont.copyWith(
        color: Colors.white,
        fontSize: 18, // Large text for accessibility
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: hindiFont.copyWith(color: AppColors.darkTextSecondary),
        hintText: hint,
        hintStyle: hindiFont.copyWith(color: AppColors.darkTextTertiary),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.darkTextTertiary)
            : null,
        suffix: suffix,
      ),
    );
  }
}
