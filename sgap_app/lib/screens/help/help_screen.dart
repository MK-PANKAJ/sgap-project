import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

/// Help & support screen with FAQs and contact info.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Contact card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text('Need help?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text('Call us at 1800-XXX-XXXX',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  child: const Text('Call Now'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          _FaqItem(
            question: 'How do I log my income?',
            answer: 'Tap the mic button on the dashboard and speak your income details in Hindi or English.',
          ),
          _FaqItem(
            question: 'What is Trust Score?',
            answer: 'Trust Score is a measure of your financial reliability based on income consistency, employer verification, and repayment history.',
          ),
          _FaqItem(
            question: 'How can I apply for a loan?',
            answer: 'Go to Loans section, view available offers based on your Trust Score, and tap Apply Now.',
          ),
          _FaqItem(
            question: 'Is my data safe?',
            answer: 'Yes, all your data is encrypted and stored securely. We follow RBI guidelines for data protection.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(question,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            )),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.darkTextTertiary,
        children: [
          Text(answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
                height: 1.5,
              )),
        ],
      ),
    );
  }
}
