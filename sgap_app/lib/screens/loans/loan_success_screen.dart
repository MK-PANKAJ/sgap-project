import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Loan application success screen.
class LoanSuccessScreen extends StatelessWidget {
  const LoanSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 64, color: AppColors.success),
              ),
              const SizedBox(height: 32),
              Text('Application Submitted! 🎉',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                'Your loan application has been submitted successfully. '
                'You will receive a notification once it is approved.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkTextSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: 'Lender', value: 'QuickCash NBFC'),
                    _DetailRow(label: 'Amount', value: '₹15,000'),
                    _DetailRow(label: 'Tenure', value: '3 months'),
                    _DetailRow(label: 'Expected approval', value: '2 hours'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil('/dashboard', (r) => false),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/loan-home'),
                child: const Text('View My Loans'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.darkTextTertiary)),
          Text(value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
