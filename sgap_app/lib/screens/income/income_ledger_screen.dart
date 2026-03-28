import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/status_badge.dart';

/// Income ledger showing all recorded income entries.
class IncomeLedgerScreen extends StatelessWidget {
  const IncomeLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Income Ledger'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Monthly summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryItem(label: 'This Month', value: '₹12,500', theme: theme),
                Container(width: 1, height: 40, color: AppColors.darkBorder),
                _SummaryItem(label: 'Last Month', value: '₹11,200', theme: theme),
                Container(width: 1, height: 40, color: AppColors.darkBorder),
                _SummaryItem(label: 'Verified', value: '₹9,800', theme: theme),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Entries',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _IncomeEntry(
            amount: 850,
            source: 'Daily wage - Site A',
            date: '25 Mar 2024',
            verified: true,
          ),
          _IncomeEntry(
            amount: 500,
            source: 'Overtime work',
            date: '24 Mar 2024',
            verified: false,
          ),
          _IncomeEntry(
            amount: 1200,
            source: 'Contract payment',
            date: '22 Mar 2024',
            verified: true,
          ),
          _IncomeEntry(
            amount: 800,
            source: 'Daily wage - Site B',
            date: '21 Mar 2024',
            verified: true,
          ),
          _IncomeEntry(
            amount: 650,
            source: 'Daily wage - Site A',
            date: '20 Mar 2024',
            verified: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/voice-logger'),
        icon: const Icon(Icons.mic_rounded),
        label: const Text('Log Income'),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.darkTextTertiary)),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

class _IncomeEntry extends StatelessWidget {
  final double amount;
  final String source;
  final String date;
  final bool verified;

  const _IncomeEntry({
    required this.amount,
    required this.source,
    required this.date,
    required this.verified,
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_downward_rounded,
                color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(date,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.darkTextTertiary)),
                    const SizedBox(width: 8),
                    StatusBadge(
                      customLabel: verified ? 'Verified' : 'Pending',
                      state: verified ? StatusBadgeState.confirmed : StatusBadgeState.pending,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toInt()}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
