import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class LoanSuccessScreen extends StatefulWidget {
  const LoanSuccessScreen({super.key});
  @override
  State<LoanSuccessScreen> createState() => _LoanSuccessScreenState();
}

class _LoanSuccessScreenState extends State<LoanSuccessScreen> with TickerProviderStateMixin {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 40),
            // Animated checkmark
            ScaleTransition(
              scale: _checkScale,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)]),
                  boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 12))]),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(opacity: _fadeIn, child: Column(children: [
              Text('लोन मंज़ूर! 🎉', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28)),
              const SizedBox(height: 8),
              Text('बधाई हो! आपका लोन अप्रूव हो गया है', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 15)),
              const SizedBox(height: 28),
              // Loan details summary
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                child: Column(children: [
                  _DetailRow('लोन राशि', '₹50,000', AppColors.primary),
                  _divider(),
                  _DetailRow('ब्याज दर', '10.0%', AppColors.warning),
                  _divider(),
                  _DetailRow('EMI', '₹2,320/महीना', Colors.white),
                  _divider(),
                  _DetailRow('अवधि', '24 महीने', AppColors.secondary),
                  _divider(),
                  _DetailRow('लेंडर', 'Grameen Finance', AppColors.info),
                ]),
              ),
              const SizedBox(height: 20),
              // Disbursement estimate
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('पैसे कब मिलेंगे?', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
                    Text('4 घंटे में मिलेगा', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),
              // EMI schedule (first 3 months)
              _buildSectionTitle('EMI शेड्यूल', hindi),
              const SizedBox(height: 12),
              ...List.generate(3, (i) {
                final month = ['अप्रैल 2026', 'मई 2026', 'जून 2026'][i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Container(width: 32, height: 32,
                        decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text('${i + 1}', style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 14)))),
                      const SizedBox(width: 12),
                      Text(month, style: hindi.copyWith(color: Colors.white, fontSize: 14)),
                    ]),
                    Text('₹2,320', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                );
              }),
              const SizedBox(height: 24),
              // Share/download button
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _showSnack(context, 'डाउनलोड जल्द आ रहा है'),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text('डाउनलोड', style: hindi.copyWith(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(0, 48)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _showSnack(context, 'शेयर जल्द आ रहा है'),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text('शेयर करो', style: hindi.copyWith(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(0, 48), elevation: 0),
                )),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 52,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false),
                  child: Text('डैशबोर्ड पर जाओ →', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16)),
                )),
              const SizedBox(height: 20),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, TextStyle hindi) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)));
  }

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.notoSansDevanagari()), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _DetailRow(this.label, this.value, this.valueColor);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 14)),
      Text(value, style: GoogleFonts.notoSansDevanagari(color: valueColor, fontWeight: FontWeight.w700, fontSize: 15)),
    ]));
}

Widget _divider() => Divider(color: AppColors.darkBorder.withValues(alpha: 0.4), height: 1);
