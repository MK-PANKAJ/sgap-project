import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart'; // Naya
import '../../core/localization/app_translations.dart'; // Naya
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/coming_soon_card.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});
  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Language watch
    
    // Yahan faqs ko lang ke hisaab se switch kiya
    final faqs = lang == 'English' ? const [
      _FAQ('What is S-GAP?', 'S-GAP (Smart Gig-worker Assistance Platform) helps gig and informal workers log income, build credit profiles, and get easy loans.'),
      _FAQ('How to improve Trust Score?', 'Log income daily, get employer verifications, link e-Shram card, and repay loan EMIs on time.'),
      _FAQ('How to log income via voice?', 'Tap the "Voice Log" button on the dashboard, speak your earnings — e.g. "Got ₹800 from Suresh bhai". The app extracts amount, employer, and date.'),
      _FAQ('How to get a loan?', 'Go to the Loan section, select your purpose, set amount and apply. You will get 2-3 offers from the OCEN network.'),
      _FAQ('Is my data secure?', 'Yes! All your data is encrypted. We do not share data without your permission. You can delete your data anytime.'),
      _FAQ('What is employer verification?', 'When you log income, your employer can verify it via their phone. This heavily boosts your Trust Score.'),
      _FAQ('How to avail government schemes?', 'Go to the Schemes section, check your eligible schemes, and click "Apply Now" to go directly to the govt portal.'),
      _FAQ('Is the app free?', 'Yes, S-GAP is completely free. There are no hidden charges.'),
    ] : const [
      _FAQ('S-GAP क्या है?', 'S-GAP (Smart Gig-worker Assistance Platform) एक ऐसा प्लेटफ़ॉर्म है जो गिग और अनौपचारिक कामगारों को अपनी आय दर्ज करने, क्रेडिट प्रोफ़ाइल बनाने, और आसान लोन प्राप्त करने में मदद करता है।'),
      _FAQ('ट्रस्ट स्कोर कैसे बढ़ाएं?', 'रोज़ आय लॉग करें, नियोक्ता से सत्यापन करवाएं, e-Shram कार्ड लिंक करें, और लोन EMI समय पर चुकाएं।'),
      _FAQ('आवाज़ से आय कैसे दर्ज करें?', 'डैशबोर्ड पर "आवाज़ से लॉग करो" बटन दबाएं, अपनी कमाई हिंदी में बोलें — जैसे "आज सुरेश भाई से ₹800 मिले"। ऐप खुद राशि, नियोक्ता, और तारीख समझ लेगा।'),
      _FAQ('लोन कैसे मिलेगा?', 'लोन सेक्शन में जाएं, अपनी ज़रूरत चुनें, राशि सेट करें और अप्लाई करें। OCEN नेटवर्क से आपको 2-3 ऑफर मिलेंगे।'),
      _FAQ('क्या मेरा डेटा सुरक्षित है?', 'हां! आपका सारा डेटा एन्क्रिप्टेड है। हम बिना आपकी अनुमति के किसी को डेटा नहीं देते। आप कभी भी अपना डेटा डिलीट कर सकते हैं।'),
      _FAQ('नियोक्ता सत्यापन क्या है?', 'जब आप आय दर्ज करते हैं, तो आपका नियोक्ता अपने फ़ोन से उसकी पुष्टि कर सकता है। इससे आपका ट्रस्ट स्कोर बढ़ता है।'),
      _FAQ('सरकारी योजनाओं का लाभ कैसे लें?', 'योजना सेक्शन में जाएं, अपनी पात्र योजनाएं देखें, और "अभी अप्लाई करो" बटन से सीधे सरकारी पोर्टल पर जाएं।'),
      _FAQ('ऐप मुफ़्त है?', 'हां, S-GAP पूरी तरह मुफ़्त है। कोई छुपा शुल्क नहीं है।'),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'help_title')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.darkCard]), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
            child: Column(children: [
              const Text('🤝', style: TextStyle(fontSize: 36)), const SizedBox(height: 8),
              Text(tr(lang, 'here_to_help'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)), const SizedBox(height: 4),
              Text(tr(lang, 'see_faqs_below'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 24),
          Text(tr(lang, 'faqs_title'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          ...List.generate(faqs.length, (i) {
            final faq = faqs[i];
            final expanded = i == _expandedIndex;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 300 + (i * 50)), curve: Curves.easeOut,
              builder: (c, v, child) => Opacity(opacity: v, child: child),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: expanded ? AppColors.primary.withValues(alpha: 0.4) : AppColors.darkBorder, width: expanded ? 1 : 0.5)),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)))),
                    title: Text(faq.question, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: AnimatedRotation(turns: expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary)),
                    onExpansionChanged: (v) => setState(() => _expandedIndex = v ? i : -1), initiallyExpanded: expanded,
                    children: [Text(faq.answer, style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13, height: 1.5))],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(tr(lang, 'need_direct_help'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_rounded, color: AppColors.success, size: 22)),
              title: Text(tr(lang, 'talk_to_us'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text(tr(lang, 'call_support_hindi'), style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
              onTap: () => _snack(tr(lang, 'call_support_soon')),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          const ComingSoonCard(featureName: 'WhatsApp', phaseBadgeText: 'Phase 2', icon: Icons.chat_rounded),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.play_circle_rounded, color: AppColors.info, size: 22)),
              title: Text(tr(lang, 'how_to_use_app'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text(tr(lang, 'watch_video_tutorial'), style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
              onTap: () => _snack(tr(lang, 'video_tutorial_soon')),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.notoSansDevanagari()), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

class _FAQ { final String question, answer; const _FAQ(this.question, this.answer); }