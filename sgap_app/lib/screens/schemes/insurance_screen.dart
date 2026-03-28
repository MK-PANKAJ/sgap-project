import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/coming_soon_card.dart';

/// Insurance products screen placeholder.
class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Insurance'),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: ComingSoonCard(
          featureName: 'Insurance Products',
          phaseBadgeText:
              'Affordable micro-insurance plans designed for gig workers. '
              'Health, life, and accident coverage at low premiums.',
          icon: Icons.health_and_safety_rounded,
        ),
      ),
    );
  }
}
