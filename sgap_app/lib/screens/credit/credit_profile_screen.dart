import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart'; 
import '../../core/localization/app_translations.dart'; 
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/trust_score_gauge.dart';
import '../../widgets/trust_score_history.dart';

class CreditProfileScreen extends ConsumerStatefulWidget {
  const CreditProfileScreen({super.key});
  @override
  ConsumerState<CreditProfileScreen> createState() => _CreditProfileScreenState();
}

class _CreditProfileScreenState extends ConsumerState<CreditProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _trustData = {};
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await SecureStorage.instance.getWorkerProfile();
    final String workerId = profile?['id']?.toString() ?? profile?['user_id']?.toString() ?? '';
    final data = await MockApiService.instance.getTrustScore(workerId);
    if (!mounted) return;
    setState(() { _trustData = data; _isLoading = false; });
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider); 
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(
        title: tr(lang, 'credit_profile_title'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, 'share_soon'), style: GoogleFonts.notoSansDevanagari()), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(opacity: _fadeIn, child: _buildContent(theme, lang)),
    );
  }

  Widget _buildContent(ThemeData theme, String lang) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final score = (_trustData['score'] as int?) ?? 720;
    final band = (_trustData['band_hindi'] as String?) ?? tr(lang, 'band_good');
    final maxScore = (_trustData['max_score'] as int?) ?? 900;
    final factors = (_trustData['factors'] as Map<String, dynamic>?) ?? {};
    final tips = (_trustData['tips'] as List<dynamic>?) ?? [];

    final componentScores = <MapEntry<String, int>>[
      MapEntry(tr(lang, 'comp_inc_cons'), (factors['income_consistency']?['score'] as int?) ?? 82),
      MapEntry(tr(lang, 'comp_ver_rate'), (factors['employer_verification']?['score'] as int?) ?? 75),
      MapEntry(tr(lang, 'comp_inc_stab'), 78),
      MapEntry(tr(lang, 'comp_plat_ten'), 88),
      MapEntry(tr(lang, 'comp_emp_count'), 65),
      MapEntry(tr(lang, 'comp_rep_hist'), (factors['repayment_history']?['score'] as int?) ?? 90),
    ];
    final historyScores = [580.0, 620.0, 650.0, 680.0, 700.0, 720.0];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(height: 12),
        TrustScoreGauge(score: score, size: 220, strokeWidth: 18),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.success.withValues(alpha: 0.15))),
          child: Text(band, style: hindi.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${tr(lang, 'to_excellent')} ', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
          Text('${maxScore - score} ', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(tr(lang, 'points_left'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
        ]),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: score / maxScore, minHeight: 6, backgroundColor: AppColors.darkBorder, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)))),
        const SizedBox(height: 24),
        _buildSectionTitle(tr(lang, 'score_components')),
        const SizedBox(height: 12),
        ...componentScores.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _ComponentBar(label: entry.key, score: entry.value))),
        const SizedBox(height: 24),
        _buildSectionTitle(tr(lang, 'history_6m')),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)), child: TrustScoreHistory(monthlyScores: historyScores)),
        const SizedBox(height: 24),
        _buildSectionTitle(tr(lang, 'improvement_tips')),
        const SizedBox(height: 12),
        ...tips.asMap().entries.map((entry) => _TipCard(tip: entry.value.toString(), index: entry.key)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 56,
          child: OutlinedButton.icon(
            onPressed: () { HapticFeedback.lightImpact(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, 'share_soon'), style: GoogleFonts.notoSansDevanagari()), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); },
            icon: const Icon(Icons.share_rounded), label: Text(tr(lang, 'share_score_btn'), style: hindi.copyWith(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildSectionTitle(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)));
}

class _ComponentBar extends StatelessWidget {
  final String label; final int score;
  const _ComponentBar({required this.label, required this.score});
  Color _barColor(int s) { if (s < 40) return AppColors.error; if (s < 60) return AppColors.warning; if (s < 80) return AppColors.success; return AppColors.trustExcellent; }
  @override Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari(); final color = _barColor(score);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13, fontWeight: FontWeight.w500)), Text('$score/100', style: hindi.copyWith(color: color, fontSize: 13, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 6),
      TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: score / 100), duration: const Duration(milliseconds: 1200), curve: Curves.easeOutCubic, builder: (ctx, val, _) => ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: val, minHeight: 8, backgroundColor: AppColors.darkBorder, valueColor: AlwaysStoppedAnimation<Color>(color)))),
    ]);
  }
}

class _TipCard extends StatelessWidget {
  final String tip; final int index;
  const _TipCard({required this.tip, required this.index});
  @override Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 500 + (index * 150)), curve: Curves.easeOut,
      builder: (ctx, val, child) => Opacity(opacity: val, child: Transform.translate(offset: Offset(0, 12 * (1 - val)), child: child)),
      child: Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)))), const SizedBox(width: 12), Expanded(child: Text(tip, style: hindi.copyWith(color: Colors.white, fontSize: 14, height: 1.5)))])),
    );
  }
}