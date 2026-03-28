import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/coming_soon_card.dart';

/// Employer dashboard for managing workers and verifying income.
class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Employer Dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats summary
            Row(
              children: [
                _StatCard(label: 'Workers', value: '24', icon: Icons.people_rounded),
                const SizedBox(width: 12),
                _StatCard(label: 'Pending', value: '5', icon: Icons.pending_actions_rounded),
              ],
            ),
            const SizedBox(height: 24),
            Text('Verification Requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            _VerificationItem(name: 'Ramesh Kumar', amount: '₹850', date: 'Today'),
            _VerificationItem(name: 'Suresh Yadav', amount: '₹1,200', date: 'Yesterday'),
            _VerificationItem(name: 'Priya Devi', amount: '₹500', date: 'Yesterday'),
            const SizedBox(height: 24),
            const ComingSoonCard(
              featureName: 'Bulk Verification',
              phaseBadgeText: 'Verify multiple workers\' income at once.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
                Text(label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.darkTextTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationItem extends StatelessWidget {
  final String name;
  final String amount;
  final String date;

  const _VerificationItem({
    required this.name,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.secondary.withOpacity(0.15),
            child: const Icon(Icons.person, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                Text('$amount • $date',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.darkTextTertiary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
