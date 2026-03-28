import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

/// Loan home screen showing active loans and available offers.
class LoanHomeScreen extends StatelessWidget {
  const LoanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Loans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eligibility banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You\'re eligible for',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text('₹25,000 – ₹50,000',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/loan-offers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('View Loan Offers'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Active Loans',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            _ActiveLoanCard(),
            const SizedBox(height: 24),
            Text('Repayment Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            _EmiItem(month: 'Jan 2024', amount: 3650, paid: true),
            _EmiItem(month: 'Feb 2024', amount: 3650, paid: true),
            _EmiItem(month: 'Mar 2024', amount: 3650, paid: true),
            _EmiItem(month: 'Apr 2024', amount: 3650, paid: false, isNext: true),
            _EmiItem(month: 'May 2024', amount: 3650, paid: false),
            _EmiItem(month: 'Jun 2024', amount: 3650, paid: false),
          ],
        ),
      ),
    );
  }
}

class _ActiveLoanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MicroFin Bank',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Active',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LoanStat(label: 'Borrowed', value: '₹20,000'),
              _LoanStat(label: 'Remaining', value: '₹12,500'),
              _LoanStat(label: 'EMI', value: '₹3,650'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.darkBorder,
              valueColor: AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('3 of 6 EMIs paid',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.darkTextTertiary)),
        ],
      ),
    );
  }
}

class _LoanStat extends StatelessWidget {
  final String label;
  final String value;

  const _LoanStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.darkTextTertiary)),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

class _EmiItem extends StatelessWidget {
  final String month;
  final double amount;
  final bool paid;
  final bool isNext;

  const _EmiItem({
    required this.month,
    required this.amount,
    required this.paid,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? AppColors.primary.withOpacity(0.3) : AppColors.darkBorder,
          width: isNext ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            paid
                ? Icons.check_circle_rounded
                : isNext
                    ? Icons.schedule_rounded
                    : Icons.radio_button_unchecked_rounded,
            color: paid
                ? AppColors.success
                : isNext
                    ? AppColors.primary
                    : AppColors.darkTextTertiary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(month,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                )),
          ),
          Text('₹${amount.toInt()}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: paid ? AppColors.darkTextTertiary : Colors.white,
                fontWeight: FontWeight.w600,
                decoration: paid ? TextDecoration.lineThrough : null,
              )),
        ],
      ),
    );
  }
}
