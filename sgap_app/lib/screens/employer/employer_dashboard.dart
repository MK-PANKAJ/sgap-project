import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/sgap_app_bar.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});
  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  bool _isLoading = true;

  // Mock data
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
      _pendingConfirmations = [
        {'id': 'c-001', 'worker': 'रमेश कुमार', 'amount': 800, 'date': '27 मार्च 2026', 'work_type': 'Construction'},
        {'id': 'c-002', 'worker': 'सुनीता देवी', 'amount': 650, 'date': '26 मार्च 2026', 'work_type': 'Painting'},
        {'id': 'c-003', 'worker': 'महेश यादव', 'amount': 1200, 'date': '25 मार्च 2026', 'work_type': 'Electrical'},
        {'id': 'c-004', 'worker': 'प्रिया शर्मा', 'amount': 500, 'date': '25 मार्च 2026', 'work_type': 'Labour'},
      ];
      _pendingCount = _pendingConfirmations.length;
      _isLoading = false;
    });
    _fadeCtrl.forward();
  }

  void _confirmEntry(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _pendingConfirmations.removeAt(index);
      _pendingCount = _pendingConfirmations.length;
      _totalConfirmed++;
    });
    _snack('✅ सत्यापित कर दिया!');
  }

  void _disputeEntry(int index) {
    HapticFeedback.heavyImpact();
    final entry = _pendingConfirmations[index];
    setState(() {
      _pendingConfirmations.removeAt(index);
      _pendingCount = _pendingConfirmations.length;
    });
    _snack('❌ ${entry['worker']} की एंट्री विवादित की गई');
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'नियोक्ता डैशबोर्ड'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  // Stats
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                    child: Row(children: [
                      _Stat('कामगार', '$_totalWorkers', AppColors.info),
                      Container(width: 1, height: 36, color: AppColors.darkBorder.withValues(alpha: 0.5)),
                      _Stat('सत्यापित', '$_totalConfirmed', AppColors.success),
                      Container(width: 1, height: 36, color: AppColors.darkBorder.withValues(alpha: 0.5)),
                      _Stat('बाकी', '$_pendingCount', _pendingCount > 0 ? AppColors.warning : AppColors.darkTextTertiary),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Pending header
                  Row(children: [
                    Text('सत्यापन बाकी', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(width: 8),
                    if (_pendingCount > 0) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: Text('$_pendingCount', style: hindi.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Pending list
                  if (_pendingConfirmations.isEmpty)
                    _buildEmptyState(hindi)
                  else
                    ...List.generate(_pendingConfirmations.length, (i) {
                      final entry = _pendingConfirmations[i];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 350 + (i * 80)),
                        curve: Curves.easeOut,
                        builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
                        child: _ConfirmationCard(
                          entry: entry,
                          onConfirm: () => _confirmEntry(i),
                          onDispute: () => _disputeEntry(i),
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildEmptyState(TextStyle hindi) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded, size: 32, color: AppColors.success)),
        const SizedBox(height: 14),
        Text('सब ठीक है! 🎉', style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        const SizedBox(height: 4),
        Text('कोई सत्यापन बाकी नहीं है', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 14)),
      ]),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.notoSansDevanagari(fontSize: 15)), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

class _ConfirmationCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onConfirm, onDispute;
  const _ConfirmationCard({required this.entry, required this.onConfirm, required this.onDispute});

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final worker = entry['worker'] as String? ?? '';
    final amount = entry['amount'] as int? ?? 0;
    final date = entry['date'] as String? ?? '';
    final workType = entry['work_type'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(worker.isNotEmpty ? worker[0] : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(worker, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.darkTextTertiary),
              const SizedBox(width: 4),
              Text(date, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
              const SizedBox(width: 10),
              Icon(Icons.work_outline_rounded, size: 12, color: AppColors.darkTextTertiary),
              const SizedBox(width: 4),
              Text(workType, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
            ]),
          ])),
          Text('₹$amount', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 22)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: SizedBox(height: 44, child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text('सत्यापित', style: hindi.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          ))),
          const SizedBox(width: 10),
          Expanded(child: SizedBox(height: 44, child: OutlinedButton.icon(
            onPressed: onDispute,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text('विवाद', style: hindi.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ))),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.notoSansDevanagari(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
    const SizedBox(height: 2),
    Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 12)),
  ]));
}
