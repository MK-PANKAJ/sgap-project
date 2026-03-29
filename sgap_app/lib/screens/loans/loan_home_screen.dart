import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart'; // Language State
import '../../core/localization/app_translations.dart'; // Dictionary
import '../../widgets/sgap_app_bar.dart';

class LoanHomeScreen extends ConsumerStatefulWidget {
  const LoanHomeScreen({super.key});
  @override
  ConsumerState<LoanHomeScreen> createState() => _LoanHomeScreenState();
}

class _LoanHomeScreenState extends ConsumerState<LoanHomeScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true, _isApplying = false;
  Map<String, dynamic> _eligibility = {};
  double _loanAmount = 50000;
  
  // Ab hum keys use karenge dropdown ke liye, taaki language badalne par problem na ho
  String _selectedPurposeKey = 'medical';
  final _purposeKeys = ['medical', 'wedding', 'home', 'business', 'other'];
  
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadEligibility();
  }

  Future<void> _loadEligibility() async {
    final profile = await SecureStorage.instance.getWorkerProfile();
    final String workerId = profile?['id']?.toString() ?? profile?['user_id']?.toString() ?? '';
    final results = await MockApiService.instance.getLoanEligibility(workerId);
    if (!mounted) return;
    setState(() { _eligibility = results; _isLoading = false; });
    _fadeCtrl.forward();
  }

  Future<void> _applyForLoan() async {
    setState(() => _isApplying = true);
    HapticFeedback.heavyImpact();
    await MockApiService.instance.applyLoan({'amount': _loanAmount.round(), 'purpose': _selectedPurposeKey});
    if (!mounted) return;
    setState(() => _isApplying = false);
    Navigator.of(context).pushNamed('/loan-offers');
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  IconData _purposeIcon(String pKey) {
    switch (pKey) {
      case 'medical': return Icons.local_hospital_rounded;
      case 'wedding': return Icons.celebration_rounded;
      case 'home': return Icons.home_rounded;
      case 'business': return Icons.store_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  String _fmt(int n) {
    if (n >= 100000) return '${n ~/ 100000},${((n % 100000) ~/ 1000).toString().padLeft(2, '0')},000';
    if (n >= 1000) return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Check Language

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'get_loan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  _buildEligibilityCard(hindi, lang),
                  const SizedBox(height: 28),
                  Text(tr(lang, 'how_much_loan'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildSliderCard(theme, hindi),
                  const SizedBox(height: 24),
                  Text(tr(lang, 'why_loan'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildPurposeDropdown(hindi, lang),
                  const SizedBox(height: 32),
                  _buildApplyButton(hindi, lang),
                  const SizedBox(height: 32),
                  Text(tr(lang, 'active_loan'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildActiveLoanPlaceholder(hindi, lang),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildEligibilityCard(TextStyle hindi, String lang) {
    final eligible = (_eligibility['is_eligible'] as bool?) ?? false;
    final maxAmt = (_eligibility['max_loan_amount'] as int?) ?? 100000;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: eligible ? [AppColors.success.withValues(alpha: 0.08), AppColors.darkCard] : [AppColors.error.withValues(alpha: 0.08), AppColors.darkCard]),
        border: Border.all(color: eligible ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 56, height: 56,
            decoration: BoxDecoration(color: eligible ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(eligible ? Icons.check_circle_rounded : Icons.cancel_rounded, color: eligible ? AppColors.success : AppColors.error, size: 28)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(eligible ? tr(lang, 'eligible_yes') : tr(lang, 'eligible_no'), style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 4),
            Text('${tr(lang, 'trust_score')}: 720', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 13)),
          ])),
        ]),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.darkBackground.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat(tr(lang, 'max_limit'), '₹${(maxAmt ~/ 1000)}K', AppColors.primary),
            Container(width: 1, height: 30, color: AppColors.darkBorder),
            _Stat(tr(lang, 'interest_rate_label'), '10-18%', AppColors.info),
            Container(width: 1, height: 30, color: AppColors.darkBorder),
            _Stat(tr(lang, 'tenure_label'), tr(lang, 'months_24'), AppColors.secondary),
          ])),
      ]),
    );
  }

  Widget _buildSliderCard(ThemeData theme, TextStyle hindi) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(children: [
        Text('₹${_fmt(_loanAmount.round())}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 36)),
        const SizedBox(height: 16),
        SliderTheme(data: SliderThemeData(activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.darkBorder, thumbColor: AppColors.primary, overlayColor: AppColors.primary.withValues(alpha: 0.15), trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12)),
          child: Slider(value: _loanAmount, min: 5000, max: 200000, divisions: 39, onChanged: (v) { setState(() => _loanAmount = v); HapticFeedback.selectionClick(); })),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('₹5,000', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 12)),
            Text('₹2,00,000', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 12)),
          ])),
      ]),
    );
  }

  Widget _buildPurposeDropdown(TextStyle hindi, String lang) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: _selectedPurposeKey, dropdownColor: AppColors.darkCard, isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
        style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontSize: 16),
        items: _purposeKeys.map((pKey) => DropdownMenuItem(value: pKey, child: Row(children: [Icon(_purposeIcon(pKey), size: 20, color: AppColors.primary), const SizedBox(width: 12), Text(tr(lang, pKey))]))).toList(),
        onChanged: (v) { if (v != null) setState(() => _selectedPurposeKey = v); },
      )),
    );
  }

  Widget _buildApplyButton(TextStyle hindi, String lang) {
    final eligible = (_eligibility['is_eligible'] as bool?) ?? false;
    return SizedBox(width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: (eligible && !_isApplying) ? _applyForLoan : null,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        child: _isApplying
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(tr(lang, 'apply_loan'), style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.w700, fontSize: 17)),
      ));
  }

  Widget _buildActiveLoanPlaceholder(TextStyle hindi, String lang) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.darkTextTertiary),
        const SizedBox(height: 12),
        Text(tr(lang, 'no_active_loan'), style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 15)),
        const SizedBox(height: 4),
        Text(tr(lang, 'apply_from_above'), style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 13)),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: GoogleFonts.notoSansDevanagari(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
    const SizedBox(height: 2),
    Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 11)),
  ]);
}