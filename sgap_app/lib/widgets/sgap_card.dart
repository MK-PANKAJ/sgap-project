import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SgapCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useGradient;
  final VoidCallback? onTap;

  const SgapCard({
    super.key,
    required this.child,
    this.padding,
    this.useGradient = false,
    this.onTap,
  });

  @override
  State<SgapCard> createState() => _SgapCardState();
}

class _SgapCardState extends State<SgapCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: widget.useGradient ? AppColors.darkCardGradient : null,
          color: widget.useGradient ? null : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: content,
      );
    }
    return content;
  }
}
