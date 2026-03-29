import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod add kiya
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart'; 
import '../../core/localization/app_translations.dart'; 
import '../../widgets/sgap_app_bar.dart';

class EmployerDashboard extends ConsumerStatefulWidget {
  const EmployerDashboard({super.key});
  @override
  ConsumerState<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends ConsumerState<EmployerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  bool _isLoading = true;

  int _totalWorkers = 12;
  int _totalConfirmed = 45;
  int _pendingCount = 0;
  List<Map<String, dynamic>> _pendingConfirmations = [];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      // Data waise hi rahega, translation UI layer me karenge
      _pendingConfirmations = [
        {'id': 'c-001', 'worker': 'रमेश कुमार', 'amount': 800, 'date': '27 मार्च 2026', 'work_type': 'Construction Worker'},
        {'id': 'c-002', 'worker': 'सुनीता देवी', 'amount': 650, 'date': '26 मार्च 2026', 'work_type': 'Domestic Help'},
        {'id': 'c-003', 'worker': 'महेश यादव', 'amount': 1200, 'date': '25 मार्च 2026', 'work_type': 'Electrical'},
        {'id': 'c-004', 'worker': 'प्रिया शर्मा', 'amount': 500, 'date': '25 मार्च 2026', 'work_type': 'Labour'},
      ];
      _pendingCount = _pendingConfirmations.length;
      _isLoading = false;
    });
    _fadeCtrl.forward();
  }

  void _confirmEntry(int index, String lang) {
    HapticFeedback.mediumImpact();
    setState(() {
      _pendingConfirmations.removeAt(index);
      _pendingCount = _pendingConfirmations.length;
      _totalConfirmed++;
    });
    _snack(tr(lang, 'verified_success'));
  }

  void _disputeEntry(int index, String lang) {
    HapticFeedback.heavyImpact();
    final entry = _pendingConfirmations[index];
    final workerName = translateName(entry['worker'], lang); // Use our custom name translator
    setState(() {
      _pendingConfirmations.removeAt(index);
      _pendingCount = _pendingConfirmations.length;
    });
    _snack('❌ $workerName${tr(lang, 'entry_disputed')}');
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Language watch kar raha hai

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'employer_dash')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                    child: Row(children: [
                      _Stat(tr(lang, 'workers_label'), '$_totalWorkers', AppColors.info),
                      Container(width: 1, height: 36, color: AppColors.darkBorder.withValues(alpha: 0.5)),
                      _Stat(tr(lang, 'verified_count'), '$_totalConfirmed', AppColors.success),
                      Container(width: 1, height: 36, color: AppColors.darkBorder.withValues(alpha: 0.5)),
                      _Stat(tr(lang, 'pending_count'), '$_pendingCount', _pendingCount > 0 ? AppColors.warning : AppColors.darkTextTertiary),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Text(tr(lang, 'pending_verifications'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(width: 8),
                    if (_pendingCount > 0) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('$_pendingCount', style: hindi.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  if (_pendingConfirmations.isEmpty)
                    _buildEmptyState(hindi, lang)
                  else
                    ...List.generate(_pendingConfirmations.length, (i) {
                      final entry = _pendingConfirmations[i];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 350 + (i * 80)), curve: Curves.easeOut,
                        builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
                        child: _ConfirmationCard(
                          entry: entry, lang: lang,
                          onConfirm: () => _confirmEntry(i, lang), onDispute: () => _disputeEntry(i, lang),
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildEmptyState(TextStyle hindi, String lang) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline_rounded, size: 32, color: AppColors.success)),
        const SizedBox(height: 14),
        Text(tr(lang, 'all_good'), style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        const SizedBox(height: 4),
        Text(tr(lang, 'no_pending_verifications'), style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 14)),
      ]),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.notoSansDevanagari(fontSize: 15)), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

class _ConfirmationCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String lang;
  final VoidCallback onConfirm, onDispute;
  const _ConfirmationCard({required this.entry, required this.lang, required this.onConfirm, required this.onDispute});

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final workerName = translateName(entry['worker'] as String? ?? '', lang); // Using translator function
    final amount = entry['amount'] as int? ?? 0;
    
    // Quick translation trick for hardcoded date in demo
    String date = entry['date'] as String? ?? '';
    if (lang == 'English') date = date.replaceAll('मार्च', 'March');
    
    // Quick translation for work type
    String workType = entry['work_type'] as String? ?? '';
    if (lang == 'हिंदी' && workType == 'Construction Worker') workType = 'निर्माण मज़दूर';
    if (lang == 'हिंदी' && workType == 'Domestic Help') workType = 'घर का काम';
    if (lang == 'हिंदी' && workType == 'Electrical') workType = 'इलेक्ट्रिकल';

    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(workerName.isNotEmpty ? workerName[0] : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(workerName, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.darkTextTertiary), const SizedBox(width: 4), Text(date, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
              const SizedBox(width: 10),
              Icon(Icons.work_outline_rounded, size: 12, color: AppColors.darkTextTertiary), const SizedBox(width: 4), Text(workType, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
            ]),
          ])),
          Text('₹$amount', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 22)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: SizedBox(height: 44, child: ElevatedButton.icon(
            onPressed: onConfirm, icon: const Icon(Icons.check_rounded, size: 18), label: Text(tr(lang, 'verified_count'), style: hindi.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          ))),
          const SizedBox(width: 10),
          Expanded(child: SizedBox(height: 44, child: OutlinedButton.icon(
            onPressed: onDispute, icon: const Icon(Icons.close_rounded, size: 18), label: Text(tr(lang, 'dispute'), style: hindi.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ))),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value; final Color color;
  const _Stat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: GoogleFonts.notoSansDevanagari(color: color, fontWeight: FontWeight.w700, fontSize: 18)), const SizedBox(height: 2), Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 12))]));
}