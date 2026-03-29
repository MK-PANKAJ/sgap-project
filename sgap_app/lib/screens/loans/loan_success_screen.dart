import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart'; // Naya
import '../../core/localization/app_translations.dart'; // Naya

class LoanSuccessScreen extends ConsumerStatefulWidget {
  const LoanSuccessScreen({super.key});
  @override
  ConsumerState<LoanSuccessScreen> createState() => _LoanSuccessScreenState();
}

class _LoanSuccessScreenState extends ConsumerState<LoanSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _checkCtrl, _fadeCtrl;
  late Animation<double> _checkScale, _fadeIn;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _checkCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _fadeCtrl.forward(); });
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() { _checkCtrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Language watch

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 40),
            ScaleTransition(
              scale: _checkScale,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)]), boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 12))]),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(opacity: _fadeIn, child: Column(children: [
              Text(tr(lang, 'loan_approved'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28)),
              const SizedBox(height: 8),
              Text(tr(lang, 'congrats_approved'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 15)),
              const SizedBox(height: 28),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                child: Column(children: [
                  _DetailRow(tr(lang, 'amount'), '₹50,000', AppColors.primary), _divider(),
                  _DetailRow(tr(lang, 'interest_rate_label'), '10.0%', AppColors.warning), _divider(),
                  _DetailRow(tr(lang, 'emi'), '₹2,320/${tr(lang, 'months').replaceAll('े', 'ीना')}', Colors.white), _divider(), // Simple translation hack for /month
                  _DetailRow(tr(lang, 'duration'), '24 ${tr(lang, 'months')}', AppColors.secondary), _divider(),
                  _DetailRow(tr(lang, 'lender'), 'Grameen Finance', AppColors.info),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr(lang, 'when_money_arrive'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
                    Text(tr(lang, 'in_4_hours'), style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),
              Align(alignment: Alignment.centerLeft, child: Text(tr(lang, 'emi_schedule'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18))),
              const SizedBox(height: 12),
              ...List.generate(3, (i) {
                final monthKey = ['month_apr', 'month_may', 'month_jun'][i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${i + 1}', style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 14)))),
                      const SizedBox(width: 12),
                      Text(tr(lang, monthKey), style: hindi.copyWith(color: Colors.white, fontSize: 14)),
                    ]),
                    Text('₹2,320', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                );
              }),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _showSnack(context, tr(lang, 'download_soon')), icon: const Icon(Icons.download_rounded, size: 20), label: Text(tr(lang, 'download'), style: hindi.copyWith(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(0, 48)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _showSnack(context, tr(lang, 'share_soon')), icon: const Icon(Icons.share_rounded, size: 20), label: Text(tr(lang, 'share'), style: hindi.copyWith(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(0, 48), elevation: 0),
                )),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 52,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false),
                  child: Text(tr(lang, 'dash_arrow'), style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16)),
                )),
              const SizedBox(height: 20),
            ])),
          ]),
        ),
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.notoSansDevanagari()), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value; final Color valueColor;
  const _DetailRow(this.label, this.value, this.valueColor);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 14)), Text(value, style: GoogleFonts.notoSansDevanagari(color: valueColor, fontWeight: FontWeight.w700, fontSize: 15))]));
}

Widget _divider() => Divider(color: AppColors.darkBorder.withValues(alpha: 0.4), height: 1);