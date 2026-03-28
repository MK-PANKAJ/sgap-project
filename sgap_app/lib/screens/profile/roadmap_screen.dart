import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

/// Financial roadmap showing the worker's journey and milestones.
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'My Roadmap'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Your financial journey',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.darkTextSecondary)),
          const SizedBox(height: 24),
          _RoadmapStep(
            title: 'Create Account',
            subtitle: 'Signed up on 15 Jan 2024',
            completed: true,
            isFirst: true,
          ),
          _RoadmapStep(
            title: 'Verify Identity',
            subtitle: 'Aadhaar verified',
            completed: true,
          ),
          _RoadmapStep(
            title: 'Log 30 days of income',
            subtitle: '22/30 days completed',
            completed: false,
            inProgress: true,
          ),
          _RoadmapStep(
            title: 'Reach Trust Score 75+',
            subtitle: 'Current: 72',
            completed: false,
          ),
          _RoadmapStep(
            title: 'Get first loan',
            subtitle: 'Unlock after Trust Score 60+',
            completed: false,
          ),
          _RoadmapStep(
            title: 'Complete first repayment',
            subtitle: 'Builds repayment history',
            completed: false,
          ),
          _RoadmapStep(
            title: 'Premium member',
            subtitle: 'Access higher loan amounts',
            completed: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool completed;
  final bool inProgress;
  final bool isFirst;
  final bool isLast;

  const _RoadmapStep({
    required this.title,
    required this.subtitle,
    required this.completed,
    this.inProgress = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed ? AppColors.success : AppColors.darkBorder,
                    ),
                  ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? AppColors.success
                        : inProgress
                            ? AppColors.primary
                            : AppColors.darkBorder,
                    border: Border.all(
                      color: completed
                          ? AppColors.success
                          : inProgress
                              ? AppColors.primary
                              : AppColors.darkBorder,
                      width: 2,
                    ),
                  ),
                  child: completed
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed ? AppColors.success : AppColors.darkBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: inProgress
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: inProgress
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.darkBorder,
                  width: inProgress ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: completed
                            ? AppColors.darkTextTertiary
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: inProgress
                            ? AppColors.primary
                            : AppColors.darkTextTertiary,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
