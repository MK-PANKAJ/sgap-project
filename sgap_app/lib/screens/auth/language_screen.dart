import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/providers/language_provider.dart';
import '../../core/localization/app_translations.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});
  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final List<Map<String, dynamic>> _languages = const [
    {'code': 'hi', 'label': 'हिंदी', 'subtitle': 'Hindi', 'isActive': true, 'emoji': '🇮🇳'},
    {'code': 'en', 'label': 'English', 'subtitle': 'English', 'isActive': true, 'emoji': '🌐'},
    {'code': 'ta', 'label': 'தமிழ்', 'subtitle': 'Tamil', 'isActive': false, 'emoji': '🏛️'},
    {'code': 'te', 'label': 'తెలుగు', 'subtitle': 'Telugu', 'isActive': false, 'emoji': '🎭'},
    {'code': 'bn', 'label': 'বাংলা', 'subtitle': 'Bengali', 'isActive': false, 'emoji': '🌸'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ', 'subtitle': 'Kannada', 'isActive': false, 'emoji': '🏔️'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  Future<void> _onContinue() async {
    final lang = ref.read(languageProvider);
    await SecureStorage.instance.saveLanguage(lang);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/phone');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),
              Text(tr(currentLang, 'choose_lang'), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(tr(currentLang, 'choose_lang_sub'), style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary)),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.55),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = (currentLang == 'English' && lang['code'] == 'en') || (currentLang == 'हिंदी' && lang['code'] == 'hi');
                    final isDisabled = !(lang['isActive'] as bool);
                    
                    return GestureDetector(
                      onTap: isDisabled ? null : () {
                        // YAHA SE POORI APP KI LANGUAGE BADLEGI
                        ref.read(languageProvider.notifier).state = lang['code'] == 'en' ? 'English' : 'हिंदी';
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250), curve: Curves.easeOut,
                        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : isDisabled ? AppColors.darkCard.withValues(alpha: 0.4) : AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.primary : isDisabled ? AppColors.darkBorder.withValues(alpha: 0.4) : AppColors.darkBorder, width: isSelected ? 2 : 1)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(lang['emoji'], style: const TextStyle(fontSize: 28)), const SizedBox(height: 6),
                          Text(lang['label'], style: theme.textTheme.titleMedium?.copyWith(color: isSelected ? AppColors.primary : isDisabled ? AppColors.darkTextTertiary : AppColors.darkTextPrimary, fontWeight: FontWeight.w600)), const SizedBox(height: 2),
                          Text(isDisabled ? tr(currentLang, 'coming_soon') : lang['subtitle'], style: theme.textTheme.bodySmall?.copyWith(color: isDisabled ? AppColors.darkTextTertiary.withValues(alpha: 0.6) : AppColors.darkTextTertiary, fontSize: 13)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 58,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(tr(currentLang, 'continue_btn'), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)), const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded, size: 22)]),
                )),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }
}