import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya add kiya
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart'; // Naya add kiya
import '../../core/localization/app_translations.dart'; // Naya add kiya
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/status_badge.dart';

// ConsumerStatefulWidget lagaya hai
class IncomeLedgerScreen extends ConsumerStatefulWidget {
  const IncomeLedgerScreen({super.key});
  @override
  ConsumerState<IncomeLedgerScreen> createState() => _IncomeLedgerScreenState();
}

class _IncomeLedgerScreenState extends ConsumerState<IncomeLedgerScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      MockApiService.instance.getMonthlyIncome('worker-001'),
      MockApiService.instance.getIncomeRecords('worker-001')
    ]);
    if (!mounted) return;
    setState(() {
      _summary = results[0];
      final rData = results[1];
      _records = (rData['records'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); // Language watch kar raha hai

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'ledger_title'), showBack: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary, backgroundColor: AppColors.darkCard,
              onRefresh: () async { setState(() => _isLoading = true); await _loadData(); },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSummaryCard(hindi, lang),
                  const SizedBox(height: 28),
                  Text(tr(lang, 'all_transactions'), style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 16),
                  ..._records.map((r) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildRecordCard(r, hindi, lang))),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(TextStyle hindi, String lang) {
    final total = (_summary['total_earned'] as int?) ?? 0;
    final verified = (_summary['verified_amount'] as int?) ?? 0;
    final pending = (_summary['pending_amount'] as int?) ?? 0;

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Column(children: [
        Text(tr(lang, 'this_month_income'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        Text('₹$total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 40)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildSummaryStat(tr(lang, 'verified_label'), '₹$verified', AppColors.success, hindi),
          Container(width: 1, height: 40, color: AppColors.darkBorder),
          _buildSummaryStat(tr(lang, 'pending_label'), '₹$pending', AppColors.warning, hindi),
        ]),
      ]),
    );
  }

  Widget _buildSummaryStat(String label, String val, Color color, TextStyle hindi) {
    return Column(children: [
      Text(val, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
      const SizedBox(height: 4),
      Text(label, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
    ]);
  }

  Widget _buildRecordCard(Map<String, dynamic> record, TextStyle hindi, String lang) {
    final amount = record['amount'] ?? 0;
    final employer = record['employer_name'] ?? '-';
    final workType = record['work_type'] ?? '';
    final date = record['date'] ?? '';
    final statusStr = record['status'] as String?;

    StatusBadgeState statusState;
    if (statusStr == 'verified') statusState = StatusBadgeState.confirmed;
    else if (statusStr == 'rejected') statusState = StatusBadgeState.disputed;
    else statusState = StatusBadgeState.pending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(employer, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('$workType • $date', style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹$amount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          StatusBadge(state: statusState),
        ]),
      ]),
    );
  }
}