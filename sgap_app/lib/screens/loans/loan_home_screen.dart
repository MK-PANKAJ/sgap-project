import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/sgap_app_bar.dart';

class LoanHomeScreen extends StatefulWidget {
  const LoanHomeScreen({super.key});
  @override
  State<LoanHomeScreen> createState() => _LoanHomeScreenState();
}

class _LoanHomeScreenState extends State<LoanHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true, _isApplying = false;
  Map<String, dynamic> _eligibility = {};
  double _loanAmount = 50000;
  String _selectedPurpose = 'इलाज';
  final _purposes = ['इलाज', 'शादी', 'मकान', 'कारोबार', 'अन्य'];
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadEligibility();
  }

  Future<void> _loadEligibility() async {
    final data = await MockApiService.instance.getLoanEligibility('worker-001');
    if (!mounted) return;
    setState(() { _eligibility = data; _isLoading = false; });
    _fadeCtrl.forward();
  }

  Future<void> _applyForLoan() async {
    setState(() => _isApplying = true);
    HapticFeedback.heavyImpact();
    await MockApiService.instance.applyLoan({'amount': _loanAmount.round(), 'purpose': _selectedPurpose});
    if (!mounted) return;
    setState(() => _isApplying = false);
    Navigator.of(context).pushNamed('/loan-offers');
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  IconData _purposeIcon(String p) {
    switch (p) {
      case 'इलाज': return Icons.local_hospital_rounded;
      case 'शादी': return Icons.celebration_rounded;
      case 'मकान': return Icons.home_rounded;
      case 'कारोबार': return Icons.store_rounded;
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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'लोन लो'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  _buildEligibilityCard(hindi),
                  const SizedBox(height: 28),
                  Text('कितना लोन चाहिए?', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildSliderCard(theme, hindi),
                  const SizedBox(height: 24),
                  Text('लोन किसलिए?', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildPurposeDropdown(hindi),
                  const SizedBox(height: 32),
                  _buildApplyButton(hindi),
                  const SizedBox(height: 32),
                  Text('चालू लोन', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildActiveLoanPlaceholder(hindi),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildEligibilityCard(TextStyle hindi) {
    final eligible = (_eligibility['is_eligible'] as bool?) ?? false;
    final maxAmt = (_eligibility['max_loan_amount'] as int?) ?? 100000;
    final reason = (_eligibility['reason_hindi'] as String?) ?? '';
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
            Text(eligible ? 'आप पात्र हैं! ✅' : 'अभी पात्र नहीं', style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 4),
            Text('ट्रस्ट स्कोर: 720', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 13)),
          ])),
        ]),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.darkBackground.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat('अधिकतम', '₹${(maxAmt ~/ 1000)}K', AppColors.primary),
            Container(width: 1, height: 30, color: AppColors.darkBorder),
            _Stat('ब्याज दर', '10-18%', AppColors.info),
            Container(width: 1, height: 30, color: AppColors.darkBorder),
            _Stat('अवधि', '24 महीने', AppColors.secondary),
          ])),
        if (reason.isNotEmpty) ...[const SizedBox(height: 12), Text(reason, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 13), textAlign: TextAlign.center)],
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

  Widget _buildPurposeDropdown(TextStyle hindi) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: _selectedPurpose, dropdownColor: AppColors.darkCard, isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
        style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontSize: 16),
        items: _purposes.map((p) => DropdownMenuItem(value: p, child: Row(children: [Icon(_purposeIcon(p), size: 20, color: AppColors.primary), const SizedBox(width: 12), Text(p)]))).toList(),
        onChanged: (v) { if (v != null) setState(() => _selectedPurpose = v); },
      )),
    );
  }

  Widget _buildApplyButton(TextStyle hindi) {
    final eligible = (_eligibility['is_eligible'] as bool?) ?? false;
    return SizedBox(width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: (eligible && !_isApplying) ? _applyForLoan : null,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        child: _isApplying
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text('लोन के लिए अप्लाई करो', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.w700, fontSize: 17)),
      ));
  }

  Widget _buildActiveLoanPlaceholder(TextStyle hindi) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.darkTextTertiary),
        const SizedBox(height: 12),
        Text('अभी कोई लोन नहीं है', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 15)),
        const SizedBox(height: 4),
        Text('ऊपर से अप्लाई करो!', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 13)),
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
