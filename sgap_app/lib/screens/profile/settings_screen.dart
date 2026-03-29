import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya add kiya
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart'; // Naya add kiya
import '../../widgets/sgap_app_bar.dart';

// Dhyan do: ab ye ConsumerStatefulWidget ban gaya hai
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifyIncome = true;
  bool _notifyLoans = true;
  bool _notifySchemes = false;

  // Local dictionary for settings page only
  final Map<String, Map<String, String>> _t = {
    'हिंदी': {
      'title': 'सेटिंग्स', 'lang': 'भाषा', 'notif': 'सूचनाएं', 'data': 'डेटा',
    },
    'English': {
      'title': 'Settings', 'lang': 'Language', 'notif': 'Notifications', 'data': 'Data',
    }
  };

  @override
  Widget build(BuildContext context) {
    // Ye line Global language padhegi (e.g., 'English' ya 'हिंदी')
    final currentLang = ref.watch(languageProvider); 
    final fontStyle = GoogleFonts.notoSansDevanagari();
    
    String getText(String key) => _t[currentLang]?[key] ?? key;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: getText('title')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _sectionTitle(getText('lang'), fontStyle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: currentLang, // Global value use kar rahe hain
              isExpanded: true, dropdownColor: AppColors.darkCard,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: fontStyle.copyWith(color: Colors.white, fontSize: 16),
              items: ['हिंदी', 'English'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) { 
                if (v != null) {
                  // JAADU YAHAN HAI: Ye change karte hi puri app ki language badal jayegi!
                  ref.read(languageProvider.notifier).state = v;
                }
              },
            )),
          ),
          // Baaki tumhare UI elements (Notifications, Data export wahi same rahenge)
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, TextStyle fontStyle) {
    return Text(t, style: fontStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18));
  }
}