import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/status_badge.dart';

/// Government schemes listing screen.
class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Government Schemes'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Schemes you\'re eligible for',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _SchemeCard(
            name: 'PM-SYM (Shram Yogi Maandhan)',
            description: 'Pension scheme for unorganised workers aged 18-40.',
            benefit: '₹3,000/month pension after 60 years',
            applied: false,
          ),
          _SchemeCard(
            name: 'PMJJBY (Jeevan Jyoti Bima)',
            description: 'Life insurance cover at just ₹436/year.',
            benefit: '₹2,00,000 life cover',
            applied: true,
          ),
          _SchemeCard(
            name: 'e-Shram Card',
            description: 'National portal for unorganised workers.',
            benefit: '₹2,00,000 accidental cover',
            applied: true,
          ),
          _SchemeCard(
            name: 'PMSBY (Suraksha Bima)',
            description: 'Accidental insurance at ₹20/year.',
            benefit: '₹2,00,000 accidental cover',
            applied: false,
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final String name;
  final String description;
  final String benefit;
  final bool applied;

  const _SchemeCard({
    required this.name,
    required this.description,
    required this.benefit,
    required this.applied,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              StatusBadge(
                customLabel: applied ? 'Applied' : 'Eligible',
                state: applied ? StatusBadgeState.confirmed : StatusBadgeState.pending,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.darkTextSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '✅ $benefit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!applied) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Apply Now'),
            ),
          ],
        ],
      ),
    );
  }
}
