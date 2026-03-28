import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

/// User profile screen with account info and quick links.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + name
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Icon(Icons.person, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Ramesh Kumar',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 4),
            Text('+91 98765 43210',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.darkTextSecondary)),
            const SizedBox(height: 4),
            Text('Construction Worker',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.darkTextTertiary)),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            _ProfileTile(
              icon: Icons.map_rounded,
              label: 'My Roadmap',
              onTap: () => Navigator.of(context).pushNamed('/roadmap'),
            ),
            _ProfileTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () => Navigator.of(context).pushNamed('/help'),
            ),
            _ProfileTile(
              icon: Icons.share_rounded,
              label: 'Share S-GAP',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.info_outline_rounded,
              label: 'About S-GAP',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text('Logout',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.darkTextSecondary),
        title: Text(label,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.darkTextTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
