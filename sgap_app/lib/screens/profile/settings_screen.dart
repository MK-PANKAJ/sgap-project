import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
import '../../core/localization/app_translations.dart'; // Naya add kiya
import '../../widgets/sgap_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider); 
    final fontStyle = GoogleFonts.notoSansDevanagari();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(currentLang, 'settings_title')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _sectionTitle(tr(currentLang, 'lang_label'), fontStyle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: currentLang,
              isExpanded: true, dropdownColor: AppColors.darkCard,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: fontStyle.copyWith(color: Colors.white, fontSize: 16),
              items: ['हिंदी', 'English'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) { 
                if (v != null) {
                  ref.read(languageProvider.notifier).state = v;
                }
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, TextStyle fontStyle) {
    return Text(t, style: fontStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18));
  }
}