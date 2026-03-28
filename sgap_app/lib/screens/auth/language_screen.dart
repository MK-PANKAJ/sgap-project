import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';

/// Language selection screen — first step in onboarding.
///
/// - Hindi and English are active (tappable)
/// - Tamil, Telugu, Bengali, Kannada show "जल्द आ रहा है" (coming soon)
/// - Orange "आगे बढ़ो" CTA at the bottom
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String _selectedLanguage = 'hi';

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final List<_LanguageOption> _languages = const [
    _LanguageOption(
      code: 'hi',
      label: 'हिंदी',
      subtitle: 'Hindi',
      isActive: true,
      emoji: '🇮🇳',
    ),
    _LanguageOption(
      code: 'en',
      label: 'English',
      subtitle: 'English',
      isActive: true,
      emoji: '🌐',
    ),
    _LanguageOption(
      code: 'ta',
      label: 'தமிழ்',
      subtitle: 'Tamil',
      isActive: false,
      emoji: '🏛️',
    ),
    _LanguageOption(
      code: 'te',
      label: 'తెలుగు',
      subtitle: 'Telugu',
      isActive: false,
      emoji: '🎭',
    ),
    _LanguageOption(
      code: 'bn',
      label: 'বাংলা',
      subtitle: 'Bengali',
      isActive: false,
      emoji: '🌸',
    ),
    _LanguageOption(
      code: 'kn',
      label: 'ಕನ್ನಡ',
      subtitle: 'Kannada',
      isActive: false,
      emoji: '🏔️',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    await SecureStorage.instance.saveLanguage(_selectedLanguage);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/phone');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ── Title ──
                Text(
                  'अपनी भाषा चुनें',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose your language',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Language grid ──
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = _selectedLanguage == lang.code;
                      return _LanguageCard(
                        lang: lang,
                        isSelected: isSelected,
                        onTap: lang.isActive
                            ? () =>
                                setState(() => _selectedLanguage = lang.code)
                            : null,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ── CTA button ──
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'आगे बढ़ो',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language Card Widget ──

class _LanguageCard extends StatelessWidget {
  final _LanguageOption lang;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageCard({
    required this.lang,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !lang.isActive;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : isDisabled
                  ? AppColors.darkCard.withValues(alpha: 0.4)
                  : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDisabled
                    ? AppColors.darkBorder.withValues(alpha: 0.4)
                    : AppColors.darkBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Text(
              lang.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 6),
            // Language name
            Text(
              lang.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : isDisabled
                        ? AppColors.darkTextTertiary
                        : AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle or "coming soon"
            Text(
              isDisabled ? 'जल्द आ रहा है' : lang.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDisabled
                    ? AppColors.darkTextTertiary.withValues(alpha: 0.6)
                    : AppColors.darkTextTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ──

class _LanguageOption {
  final String code;
  final String label;
  final String subtitle;
  final bool isActive;
  final String emoji;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.subtitle,
    required this.isActive,
    required this.emoji,
  });
}
