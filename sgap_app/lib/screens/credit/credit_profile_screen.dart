import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/trust_score_gauge.dart';

/// Credit profile screen showing trust score breakdown.
class CreditProfileScreen extends StatelessWidget {
  const CreditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Credit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Trust Score Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppColors.darkCardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Column(
                children: [
                  const TrustScoreGauge(score: 72, size: 140),
                  const SizedBox(height: 16),
                  Text(
                    'Grade: B+',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '↑ Improving • Updated 25 Mar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Score Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _ScoreFactor(label: 'Identity Verification', score: 90),
            _ScoreFactor(label: 'Employer Verification', score: 85),
            _ScoreFactor(label: 'Income Consistency', score: 78),
            _ScoreFactor(label: 'Repayment History', score: 60),
            _ScoreFactor(label: 'Community Trust', score: 45),
            const SizedBox(height: 24),
            // Tips to improve
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'How to improve',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TipItem('Log income consistently every day'),
                  _TipItem('Ask your employer to verify your work'),
                  _TipItem('Pay loan EMIs on time'),
                  _TipItem('Get community references'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreFactor extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreFactor({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.darkTextSecondary)),
              Text('$score/100',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.trustScoreColor(score),
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.darkBorder,
              valueColor: AlwaysStoppedAnimation(AppColors.trustScoreColor(score)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.info)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
