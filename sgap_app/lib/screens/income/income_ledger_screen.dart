import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

/// ─────────────────────────────────────────────────────────────────
///  INCOME LEDGER — Full income history with filters & search
/// ─────────────────────────────────────────────────────────────────
class IncomeLedgerScreen extends StatefulWidget {
  const IncomeLedgerScreen({super.key});

  @override
  State<IncomeLedgerScreen> createState() => _IncomeLedgerScreenState();
}

class _IncomeLedgerScreenState extends State<IncomeLedgerScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int _selectedMonthIndex = 5; // Current month (last in list)
  int _selectedFilterIndex = 0;

  Map<String, dynamic> _incomeData = {};
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];

  final List<String> _months = [
    'अक्टू', 'नवं', 'दिसं', 'जन', 'फर', 'मार्च',
  ];
  final List<String> _filterLabels = ['सभी', 'पक्का', 'बाकी', 'विवाद'];

  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      MockApiService.instance.getMonthlyIncome('worker-001'),
      MockApiService.instance.getIncomeRecords('worker-001'),
    ]);

    if (!mounted) return;

    setState(() {
      _incomeData = results[0];
      final recordsData = results[1];
      _allRecords = ((recordsData['records'] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>();
      _applyFilter();
      _isLoading = false;
    });

    _fadeController.forward();
  }

  void _applyFilter() {
    switch (_selectedFilterIndex) {
      case 0: // सभी
        _filteredRecords = List.from(_allRecords);
        break;
      case 1: // पक्का (verified)
        _filteredRecords =
            _allRecords.where((r) => r['status'] == 'verified').toList();
        break;
      case 2: // बाकी (pending)
        _filteredRecords =
            _allRecords.where((r) => r['status'] == 'pending').toList();
        break;
      case 3: // विवाद (disputed/rejected)
        _filteredRecords =
            _allRecords.where((r) => r['status'] == 'rejected').toList();
        break;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(
        title: 'कमाई का हिसाब',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildContent(theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/voice-logger'),
        icon: const Icon(Icons.mic_rounded, size: 22),
        label: Text(
          'लॉग करो',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final total = (_incomeData['total_earned'] as int?) ?? 28400;
    final verified = (_incomeData['verified_amount'] as int?) ?? 24200;
    final pending = (_incomeData['pending_amount'] as int?) ?? 4200;
    final disputed = 850; // From rejected record mock

    return FadeTransition(
      opacity: _fadeIn,
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.darkCard,
        onRefresh: () async {
          setState(() => _isLoading = true);
          _fadeController.reset();
          await _loadData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Month Selector ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    final selected = index == _selectedMonthIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedMonthIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.darkBorder,
                              width: selected ? 0 : 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _months[index],
                              style: hindi.copyWith(
                                color: selected
                                    ? Colors.white
                                    : AppColors.darkTextSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Summary Row ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      _SummaryPill(
                        label: 'कुल',
                        value: '₹${_formatNumber(total)}',
                        color: Colors.white,
                      ),
                      _divider(),
                      _SummaryPill(
                        label: 'पक्का',
                        value: '₹${_formatNumber(verified)}',
                        color: AppColors.success,
                      ),
                      _divider(),
                      _SummaryPill(
                        label: 'बाकी',
                        value: '₹${_formatNumber(pending)}',
                        color: AppColors.warning,
                      ),
                      _divider(),
                      _SummaryPill(
                        label: 'विवाद',
                        value: '₹${_formatNumber(disputed)}',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter Tabs ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: List.generate(_filterLabels.length, (i) {
                    final selected = i == _selectedFilterIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedFilterIndex = i;
                            _applyFilter();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.darkBorder,
                              width: selected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Text(
                            _filterLabels[i],
                            style: hindi.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.darkTextSecondary,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Records List ──
            if (_filteredRecords.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'कोई रिकॉर्ड नहीं मिला',
                  subtitle: 'इस फ़िल्टर में अभी कोई एंट्री नहीं है',
                  buttonLabel: 'आवाज़ से लॉग करो',
                  onButtonPressed: () =>
                      Navigator.of(context).pushNamed('/voice-logger'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = _filteredRecords[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 350 + (index * 60)),
                        curve: Curves.easeOut,
                        builder: (ctx, val, child) => Opacity(
                          opacity: val,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - val)),
                            child: child,
                          ),
                        ),
                        child: _IncomeRecordTile(record: record),
                      );
                    },
                    childCount: _filteredRecords.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.darkBorder.withValues(alpha: 0.5),
      );

  String _formatNumber(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      if (remainder == 0) return '$thousands,000';
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return n.toString();
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Summary Pill Widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: hindi.copyWith(
              color: AppColors.darkTextTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: hindi.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Income Record Tile
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _IncomeRecordTile extends StatelessWidget {
  final Map<String, dynamic> record;

  const _IncomeRecordTile({required this.record});

  StatusBadgeState _mapStatus(String status) {
    switch (status) {
      case 'verified':
        return StatusBadgeState.confirmed;
      case 'pending':
        return StatusBadgeState.pending;
      case 'rejected':
        return StatusBadgeState.disputed;
      default:
        return StatusBadgeState.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hindi = GoogleFonts.notoSansDevanagari();
    final amount = (record['amount'] as int?) ?? 0;
    final employer = (record['employer_name'] as String?) ?? 'अज्ञात';
    final date = (record['date'] as String?) ?? '';
    final workType = (record['work_type'] as String?) ?? '';
    final status = (record['status'] as String?) ?? 'pending';
    final source = (record['source'] as String?) ?? '';
    final id = (record['id'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount (large)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹$amount',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(state: _mapStatus(status)),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.darkTextTertiary),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.work_outline_rounded,
                        size: 12, color: AppColors.darkTextTertiary),
                    const SizedBox(width: 4),
                    Text(
                      workType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.tag_rounded,
                        size: 11, color: AppColors.darkTextTertiary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        id,
                        style: TextStyle(
                          color: AppColors.darkTextTertiary.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Source icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: source == 'voice'
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              source == 'voice' ? Icons.mic_rounded : Icons.edit_rounded,
              size: 14,
              color: source == 'voice' ? AppColors.primary : AppColors.info,
            ),
          ),
        ],
      ),
    );
  }
}
