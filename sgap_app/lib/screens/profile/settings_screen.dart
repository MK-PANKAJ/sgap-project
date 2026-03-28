import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

/// Settings screen for app preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  final String _language = 'Hindi';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'Preferences'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            trailing: Switch(
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
              activeThumbColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            label: 'Language',
            trailing: Text(_language,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.primary)),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Security'),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change PIN',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.fingerprint_rounded,
            label: 'Biometric Login',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'App Version',
            trailing: Text('1.0.0',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.darkTextTertiary)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.darkTextTertiary,
                fontWeight: FontWeight.w600,
              )),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.darkTextSecondary, size: 22),
        title: Text(label,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.darkTextTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
