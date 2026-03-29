import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart'; // Naya
import '../../core/localization/app_translations.dart'; // Naya
import '../../widgets/sgap_app_bar.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Language watch

    // Phase lists split natively for efficiency
    final phases = lang == 'English' ? [
      _Phase(number: 1, title: 'Foundation', status: 'Live ✅', isLive: true, features: ['Voice Income Logging', 'Trust Score Dashboard', 'Employer Verification', 'Basic Loan Application', 'Govt Schemes Info', 'Insurance Info']),
      _Phase(number: 2, title: 'Expansion', status: 'Coming Soon 🚧', isLive: false, features: ['OCEN Loan Integration', 'UPI Payment Verification', 'Insurance Purchase', 'Multilingual (8 languages)', 'WhatsApp Bot']),
      _Phase(number: 3, title: 'AI', status: 'In Planning 📋', isLive: false, features: ['AI Income Prediction', 'Auto Savings Suggestions', 'Smart Scheme Matching', 'Credit Score Simulator']),
      _Phase(number: 4, title: 'Scale', status: 'Future 🔮', isLive: false, features: ['Blockchain Income Proof', 'Cross-Platform Portability', 'Community Co-op Finance', 'API Marketplace']),
    ] : [
      _Phase(number: 1, title: 'फ़ाउंडेशन', status: 'Live ✅', isLive: true, features: ['आवाज़ से आय लॉगिंग', 'ट्रस्ट स्कोर डैशबोर्ड', 'नियोक्ता सत्यापन', 'बुनियादी लोन आवेदन', 'सरकारी योजना जानकारी', 'बीमा जानकारी']),
      _Phase(number: 2, title: 'विस्तार', status: 'जल्द आ रहा है 🚧', isLive: false, features: ['OCEN लोन इंटीग्रेशन', 'UPI पेमेंट वेरिफ़िकेशन', 'बीमा खरीद', 'बहुभाषी सपोर्ट (8 भाषाएं)', 'WhatsApp बॉट']),
      _Phase(number: 3, title: 'एआई', status: 'योजना में 📋', isLive: false, features: ['AI आय भविष्यवाणी', 'ऑटो बचत सुझाव', 'स्मार्ट स्कीम मैचिंग', 'क्रेडिट स्कोर सिमुलेटर']),
      _Phase(number: 4, title: 'स्केल', status: 'भविष्य 🔮', isLive: false, features: ['ब्लॉकचेन आय प्रमाण', 'क्रॉस-प्लेटफ़ॉर्म पोर्टेबिलिटी', 'सामुदायिक सहकारी वित्त', 'API मार्केटप्लेस']),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'roadmap_title')),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: phases.length,
        itemBuilder: (ctx, i) {
          final phase = phases[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 400 + (i * 150)), curve: Curves.easeOut,
            builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
            child: _buildPhaseCard(phase, i, phases.length, hindi, lang),
          );
        },
      ),
    );
  }

  Widget _buildPhaseCard(_Phase phase, int index, int total, TextStyle hindi, String lang) {
    final color = phase.isLive ? AppColors.success : AppColors.darkTextTertiary;
    final isLast = index == total - 1;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 40, child: Column(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: phase.isLive ? AppColors.success.withValues(alpha: 0.15) : AppColors.darkCard, border: Border.all(color: color, width: 2)), child: Center(child: phase.isLive ? const Icon(Icons.check_rounded, size: 16, color: AppColors.success) : Text('${phase.number}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)))),
          if (!isLast) Expanded(child: Container(width: 2, color: AppColors.darkBorder.withValues(alpha: 0.5))),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Container(
          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: phase.isLive ? AppColors.success.withValues(alpha: 0.3) : AppColors.darkBorder, width: phase.isLive ? 1.5 : 0.5), boxShadow: phase.isLive ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.06), blurRadius: 16)] : null),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${tr(lang, 'phase')} ${phase.number}: ${phase.title}', style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (phase.isLive ? AppColors.success : AppColors.primary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Text(phase.status, style: GoogleFonts.notoSansDevanagari(color: phase.isLive ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11))),
            ]),
            const SizedBox(height: 12),
            ...phase.features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Icon(phase.isLive ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 16, color: phase.isLive ? AppColors.success : AppColors.darkTextTertiary), const SizedBox(width: 8), Expanded(child: Text(f, style: GoogleFonts.notoSansDevanagari(color: phase.isLive ? Colors.white : AppColors.darkTextSecondary, fontSize: 13))), if (!phase.isLive) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)), child: Text(tr(lang, 'soon_badge'), style: GoogleFonts.notoSansDevanagari(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)))]))),
          ]),
        )),
      ]),
    );
  }
}

class _Phase { final int number; final String title, status; final bool isLive; final List<String> features; const _Phase({required this.number, required this.title, required this.status, required this.isLive, required this.features}); }