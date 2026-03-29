import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.margin,
  });

  const LoadingShimmer.card({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = 16,
    this.margin,
  });

  const LoadingShimmer.circle({
    super.key,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 48,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppColors.darkCard,
        highlightColor: AppColors.darkBorder,
        period: const Duration(milliseconds: 1200),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
