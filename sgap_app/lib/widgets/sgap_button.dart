import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SgapButtonVariant { primary, outlined, text }

class SgapButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final SgapButtonVariant variant;

  const SgapButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = SgapButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Noto Sans Devanagari for Hindi text
    final textStyle = GoogleFonts.notoSansDevanagari(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );

    final child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle),
            ],
          );

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    switch (variant) {
      case SgapButtonVariant.primary:
        return ElevatedButton(
          style: style,
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case SgapButtonVariant.outlined:
        return OutlinedButton(
          style: style,
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case SgapButtonVariant.text:
        return TextButton(
          style: style,
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}
