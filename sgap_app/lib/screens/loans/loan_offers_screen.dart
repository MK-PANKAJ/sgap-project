import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

/// Screen displaying available loan offers from different lenders.
class LoanOffersScreen extends StatelessWidget {
  const LoanOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Loan Offers'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Based on your Trust Score of 72',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _LoanOfferCard(
            lender: 'MicroFin Bank',
            amount: 25000,
            rate: 12.5,
            tenure: '6 months',
            emi: 4380,
            approvalTime: '24 hours',
            type: 'Personal',
          ),
          _LoanOfferCard(
            lender: 'QuickCash NBFC',
            amount: 15000,
            rate: 14.0,
            tenure: '3 months',
            emi: 5200,
            approvalTime: '2 hours',
            type: 'Emergency',
            highlighted: true,
          ),
          _LoanOfferCard(
            lender: 'Grameen Finance',
            amount: 50000,
            rate: 10.0,
            tenure: '12 months',
            emi: 4400,
            approvalTime: '3 days',
            type: 'Business',
          ),
        ],
      ),
    );
  }
}

class _LoanOfferCard extends StatelessWidget {
  final String lender;
  final double amount;
  final double rate;
  final String tenure;
  final double emi;
  final String approvalTime;
  final String type;
  final bool highlighted;

  const _LoanOfferCard({
    required this.lender,
    required this.amount,
    required this.rate,
    required this.tenure,
    required this.emi,
    required this.approvalTime,
    required this.type,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.darkBorder,
          width: highlighted ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lender,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(type,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'Rate', value: '$rate%'),
              _InfoChip(label: 'Tenure', value: tenure),
              _InfoChip(label: 'EMI', value: '₹${emi.toInt()}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 16, color: AppColors.darkTextTertiary),
              const SizedBox(width: 4),
              Text('Approval in $approvalTime',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.darkTextTertiary)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/loan-success'),
            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.darkTextTertiary)),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
