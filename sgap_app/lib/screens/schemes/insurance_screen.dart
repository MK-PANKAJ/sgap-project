import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart'; // Naya
import '../../core/localization/app_translations.dart'; // Naya
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/coming_soon_card.dart';

class InsuranceScreen extends ConsumerStatefulWidget {
  const InsuranceScreen({super.key});
  @override
  ConsumerState<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends ConsumerState<InsuranceScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _plans = [];
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final data = await MockApiService.instance.getInsurance();
    if (!mounted) return;
    setState(() {
      _plans = ((data['plans'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
      _isLoading = false;
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  IconData _planIcon(String type) {
    switch (type) {
      case 'life': return Icons.favorite_rounded;
      case 'accident': return Icons.shield_rounded;
      case 'health': return Icons.local_hospital_rounded;
      default: return Icons.security_rounded;
    }
  }

  Color _planColor(String type) {
    switch (type) {
      case 'life': return AppColors.error;
      case 'accident': return AppColors.warning;
      case 'health': return AppColors.success;
      default: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Language watch

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'insurance_title')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.secondary.withValues(alpha: 0.1), AppColors.darkCard]), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2))),
                    child: Row(children: [
                      const Text('🛡️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tr(lang, 'secure_family'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(tr(lang, 'affordable_plans'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_plans.length, (i) {
                    final plan = _plans[i];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 400 + (i * 120)), curve: Curves.easeOut,
                      builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child)),
                      child: _InsurancePlanCard(plan: plan, icon: _planIcon(plan['type'] as String? ?? ''), color: _planColor(plan['type'] as String? ?? ''), lang: lang),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _InsurancePlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final IconData icon;
  final Color color;
  final String lang;
  const _InsurancePlanCard({required this.plan, required this.icon, required this.color, required this.lang});

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    
    // Yaha Mock API ke names aur features English/Hindi ke hisaab se manually set kar rahe hain taaki neat lage
    final name = plan['type'] == 'life' ? (lang == 'English' ? 'Jeevan Jyoti Bima' : 'जीवन ज्योति बीमा') : 
                 plan['type'] == 'accident' ? (lang == 'English' ? 'Suraksha Bima Yojana' : 'सुरक्षा बीमा योजना') : 
                 (lang == 'English' ? 'Ayushman Bharat' : 'आयुष्मान भारत');
                 
    final premium = plan['premium_monthly'] as int? ?? 0;
    final rawCover = plan['cover_hindi'] as String? ?? '';
    final cover = tr(lang, rawCover);
    final popular = plan['popular'] as bool? ?? false;

    // Feature array translation
    final List<String> features = lang == 'English' 
      ? (plan['type'] == 'life' ? ['2 Lakh cover on death', 'No medical test required', 'Auto-debit available'] : 
         plan['type'] == 'accident' ? ['Cover for permanent disability', 'Hospitalization cash', 'Worldwide cover'] : 
         ['Up to 5 Lakhs family cover', 'Cashless treatment', 'Pre-existing diseases covered'])
      : (plan['features'] as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: popular ? color.withValues(alpha: 0.4) : AppColors.darkBorder, width: popular ? 1.5 : 0.5), boxShadow: popular ? [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))] : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            Text(cover, style: hindi.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ])),
          if (popular) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Text(tr(lang, 'popular'), style: hindi.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 11))),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.darkBackground.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(tr(lang, 'premium_label'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 14)),
            Text('₹$premium${tr(lang, 'per_month')}', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
        ),
        const SizedBox(height: 14),
        ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success), const SizedBox(width: 8), Expanded(child: Text(f, style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 12, height: 1.4)))]))),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, height: 44,
          child: ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.darkCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: ComingSoonCard(featureName: tr(lang, 'insurance_enrollment'), phaseBadgeText: 'Phase 2', icon: Icons.shield_rounded),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr(lang, 'ok_btn'), style: hindi.copyWith(color: AppColors.primary)))],
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Text(tr(lang, 'enroll_now'), style: hindi.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
          )),
      ]),
    );
  }
}