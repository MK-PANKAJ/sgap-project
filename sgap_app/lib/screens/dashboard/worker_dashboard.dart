import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/status_badge.dart';

/// ─────────────────────────────────────────────────────────────────
///  WORKER DASHBOARD — The hero screen of S-GAP
///
///  Sections (top → bottom):
///  1. Greeting header with avatar + notification bell
///  2. Trust Score card (prominent gauge, ~30% of viewport)
///  3. Monthly Income summary with animated bar
///  4. 2×2 Quick Actions grid
///  5. Recent income entries (last 3)
///  6. Bottom Navigation Bar (Hindi labels, orange active pill)
/// ─────────────────────────────────────────────────────────────────
class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  String _userName = '';
  bool _isLoading = true;

  // Data holders
  Map<String, dynamic> _trustData = {};
  Map<String, dynamic> _incomeData = {};
  List<Map<String, dynamic>> _recentRecords = [];

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _incomeBarController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _incomeBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await SecureStorage.instance.getWorkerProfile();
    _userName = profile?['name'] as String? ?? 'दोस्त';

    final results = await Future.wait([
      MockApiService.instance.getTrustScore('worker-001'),
      MockApiService.instance.getMonthlyIncome('worker-001'),
      MockApiService.instance.getIncomeRecords('worker-001'),
    ]);

    if (!mounted) return;

    setState(() {
      _trustData = results[0];
      _incomeData = results[1];
      final recordsData = results[2];
      final allRecords = (recordsData['records'] as List<dynamic>?) ?? [];
      _recentRecords =
          allRecords.take(3).cast<Map<String, dynamic>>().toList();
      _isLoading = false;
    });

    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _incomeBarController.forward();
    });
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushNamed('/income-ledger');
        break;
      case 2:
        Navigator.of(context).pushNamed('/credit-profile');
        break;
      case 3:
        Navigator.of(context).pushNamed('/loan-home');
        break;
      case 4:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _currentNavIndex = 0);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _incomeBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _isLoading ? _buildShimmerLoading() : _buildContent(theme),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  MAIN SCROLLABLE CONTENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildContent(ThemeData theme) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeIn,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.darkCard,
          onRefresh: () async {
            setState(() => _isLoading = true);
            _incomeBarController.reset();
            await _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(theme),
                ),
                const SizedBox(height: 24),
                _buildTrustScoreCard(theme),
                const SizedBox(height: 20),
                _buildIncomeCard(theme),
                const SizedBox(height: 28),
                _buildQuickActionsTitle(theme),
                const SizedBox(height: 14),
                _buildQuickActions(theme),
                const SizedBox(height: 28),
                _buildRecentEntriesTitle(theme),
                const SizedBox(height: 14),
                _buildRecentEntries(theme),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  1. HEADER — Greeting + Avatar + Bell
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // Gradient avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.35),
                AppColors.primaryDark.withValues(alpha: 0.15),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _userName.isNotEmpty ? _userName[0] : '?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Greeting text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'नमस्ते, $_userName! 👋',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                'आज कमाई कैसी रही?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        _NotificationBell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'अभी कोई नई सूचना नहीं',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: AppColors.darkCard,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  2. TRUST SCORE CARD (prominent, ~30% of screen)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildTrustScoreCard(ThemeData theme) {
    final score = (_trustData['score'] as int?) ?? 720;
    final band = (_trustData['band_hindi'] as String?) ?? 'अच्छा है ⭐⭐';
    final maxScore = (_trustData['max_score'] as int?) ?? 900;
    final trend = (_trustData['trend'] as String?) ?? 'improving';

    // Calculate the height to be ~30% of viewport
    final screenHeight = MediaQuery.of(context).size.height;
    final cardMinHeight = (screenHeight * 0.30).clamp(240.0, 340.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed('/credit-profile');
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardMinHeight),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1F30),
              Color(0xFF121620),
            ],
          ),
          border: Border.all(
            color: AppColors.darkBorder.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title row with trend badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ट्रस्ट स्कोर',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                _TrendBadge(trend: trend),
              ],
            ),
            const SizedBox(height: 16),
            // Gauge — centrepiece
            _DashboardGauge(score: score, maxScore: maxScore),
            const SizedBox(height: 14),
            // Band label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                band,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'विस्तार से देखें',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.darkTextTertiary, size: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  3. MONTHLY INCOME CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildIncomeCard(ThemeData theme) {
    final total = (_incomeData['total_earned'] as int?) ?? 28400;
    final verified = (_incomeData['verified_amount'] as int?) ?? 24200;
    final pending = (_incomeData['pending_amount'] as int?) ?? 4200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'इस महीने की कमाई',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed('/income-ledger'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'सभी देखो →',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total amount with animated counter
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: total),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, _) {
              return Text(
                '₹${_formatNumber(animValue)}',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 38,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Animated progress bar
          AnimatedBuilder(
            animation: _incomeBarController,
            builder: (context, _) {
              final progress = Curves.easeOutCubic
                  .transform(_incomeBarController.value);
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Flexible(
                        flex: (verified * progress).round().clamp(1, verified),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success,
                                AppColors.success.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: (pending * progress).round().clamp(1, pending),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warning.withValues(alpha: 0.85),
                                AppColors.warning,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Remaining unfilled space shrinks as animation progresses
                      if (progress < 1.0)
                        Flexible(
                          flex: ((1 - progress) * (verified + pending))
                              .round()
                              .clamp(0, verified + pending),
                          child: Container(
                            color: AppColors.darkBorder.withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Legend row
          Row(
            children: [
              _IncomeLegendItem(
                color: AppColors.success,
                label: 'सत्यापित',
                amount: '₹${_formatNumber(verified)}',
              ),
              const SizedBox(width: 24),
              _IncomeLegendItem(
                color: AppColors.warning,
                label: 'लंबित',
                amount: '₹${_formatNumber(pending)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  4. QUICK ACTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildQuickActionsTitle(ThemeData theme) {
    return Text(
      'जल्दी करो ⚡',
      style: theme.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _QuickActionData(
        emoji: '🎤',
        label: 'आवाज़ से\nलॉग करो',
        color: AppColors.primary,
        route: '/voice-logger',
      ),
      _QuickActionData(
        emoji: '📋',
        label: 'कमाई\nदेखो',
        color: AppColors.secondary,
        route: '/income-ledger',
      ),
      _QuickActionData(
        emoji: '💰',
        label: 'लोन\nलो',
        color: AppColors.info,
        route: '/loan-home',
      ),
      _QuickActionData(
        emoji: '🏛️',
        label: 'सरकारी\nयोजनाएं',
        color: const Color(0xFF9B59B6),
        route: '/schemes',
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                data: actions[0],
                onTap: () => Navigator.of(context).pushNamed(actions[0].route),
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                data: actions[1],
                onTap: () => Navigator.of(context).pushNamed(actions[1].route),
                delay: 80,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                data: actions[2],
                onTap: () => Navigator.of(context).pushNamed(actions[2].route),
                delay: 160,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                data: actions[3],
                onTap: () => Navigator.of(context).pushNamed(actions[3].route),
                delay: 240,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  5. RECENT ENTRIES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildRecentEntriesTitle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'हाल की एंट्री',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/income-ledger'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'सभी देखो →',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntries(ThemeData theme) {
    if (_recentRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('📝', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'अभी कोई एंट्री नहीं',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ऊपर "आवाज़ से लॉग करो" दबाओ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_recentRecords.length, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (i * 120)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RecentEntryCard(record: _recentRecords[i]),
          ),
        );
      }),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  6. BOTTOM NAVIGATION BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildBottomNav(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.darkBorder.withValues(alpha: 0.4),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'होम',
                isActive: _currentNavIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'कमाई',
                isActive: _currentNavIndex == 1,
                onTap: () => _onNavTap(1),
              ),
              _NavItem(
                icon: Icons.credit_score_rounded,
                label: 'स्कोर',
                isActive: _currentNavIndex == 2,
                onTap: () => _onNavTap(2),
              ),
              _NavItem(
                icon: Icons.account_balance_rounded,
                label: 'लोन',
                isActive: _currentNavIndex == 3,
                onTap: () => _onNavTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'प्रोफाइल',
                isActive: _currentNavIndex == 4,
                onTap: () => _onNavTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  SHIMMER LOADING STATE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildShimmerLoading() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header shimmer
            Row(
              children: [
                _shimmerBox(52, 52, isCircle: true),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(180, 22),
                    const SizedBox(height: 8),
                    _shimmerBox(120, 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Trust score card
            _shimmerBox(double.infinity, 260),
            const SizedBox(height: 20),
            // Income card
            _shimmerBox(double.infinity, 170),
            const SizedBox(height: 28),
            _shimmerBox(100, 20),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _shimmerBox(double.infinity, 100)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(double.infinity, 100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {bool isCircle = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.25, end: 0.55),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.darkCard.withValues(alpha: value),
            borderRadius: isCircle ? null : BorderRadius.circular(16),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  String _formatNumber(int n) {
    if (n < 1000) return n.toString();
    final str = n.toString();
    final last3 = str.substring(str.length - 3);
    var rest = str.substring(0, str.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NOTIFICATION BELL with bounce animation
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _NotificationBell extends StatefulWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _bellController.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _bellController,
        builder: (context, child) {
          final shake = sin(_bellController.value * pi * 4) * 3;
          return Transform.rotate(
            angle: shake * pi / 180,
            child: child,
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.darkTextSecondary,
                size: 24,
              ),
              // Red notification dot
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TREND BADGE (improving / stable)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _TrendBadge extends StatelessWidget {
  final String trend;
  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isImproving = trend == 'improving';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isImproving
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isImproving
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImproving
                ? Icons.trending_up_rounded
                : Icons.trending_flat_rounded,
            color: isImproving ? AppColors.success : AppColors.warning,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isImproving ? 'बढ़ रहा है' : 'स्थिर',
            style: TextStyle(
              color: isImproving ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DASHBOARD GAUGE (semicircular, animated, embedded)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DashboardGauge extends StatelessWidget {
  final int score;
  final int maxScore;

  const _DashboardGauge({
    required this.score,
    this.maxScore = 900,
  });

  Color _scoreColor(int s) {
    if (s < 400) return AppColors.error;
    if (s < 550) return AppColors.warning;
    if (s < 750) return AppColors.success;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeOutCubic,
      builder: (context, animScore, _) {
        return SizedBox(
          width: 200,
          height: 120,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: const Size(200, 120),
                painter: _SemiGaugePainter(
                  score: animScore,
                  maxScore: maxScore,
                  activeColor: _scoreColor(animScore),
                  trackColor: AppColors.darkBorder.withValues(alpha: 0.5),
                  strokeWidth: 16,
                  hasGlow: true,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$animScore',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 46,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/ $maxScore',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SemiGaugePainter extends CustomPainter {
  final int score;
  final int maxScore;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;
  final bool hasGlow;

  _SemiGaugePainter({
    required this.score,
    required this.maxScore,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    // Track arc
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Score arc
    final progress = (score / maxScore).clamp(0.0, 1.0);
    if (progress > 0) {
      // Glow effect
      if (hasGlow) {
        final glowPaint = Paint()
          ..color = activeColor.withAlpha(40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          pi,
          progress * pi,
          false,
          glowPaint,
        );
      }

      final scorePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        progress * pi,
        false,
        scorePaint,
      );

      // Score tick marks (5 ticks along the arc)
      final tickPaint = Paint()
        ..color = Colors.white.withAlpha(30)
        ..strokeWidth = 1;

      for (int i = 1; i < 5; i++) {
        final tickAngle = pi + (i / 5) * pi;
        final innerR = radius - strokeWidth / 2 - 2;
        final outerR = radius + strokeWidth / 2 + 2;
        final start = Offset(
          center.dx + innerR * cos(tickAngle),
          center.dy + innerR * sin(tickAngle),
        );
        final end = Offset(
          center.dx + outerR * cos(tickAngle),
          center.dy + outerR * sin(tickAngle),
        );
        canvas.drawLine(start, end, tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter old) =>
      old.score != score || old.activeColor != activeColor;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  QUICK ACTION TILE with spring tap effect
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _QuickActionData {
  final String emoji;
  final String label;
  final Color color;
  final String route;

  const _QuickActionData({
    required this.emoji,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _QuickActionTile extends StatefulWidget {
  final _QuickActionData data;
  final VoidCallback onTap;
  final int delay;

  const _QuickActionTile({
    required this.data,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + widget.delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + 0.3 * value,
          child: Opacity(
            opacity: value.clamp(0, 1),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
            decoration: BoxDecoration(
              color: widget.data.color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.data.color.withValues(alpha: 0.18),
              ),
              boxShadow: _pressed
                  ? null
                  : [
                      BoxShadow(
                        color: widget.data.color.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Text(widget.data.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text(
                  widget.data.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.data.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INCOME LEGEND
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _IncomeLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;

  const _IncomeLegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  RECENT ENTRY CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _RecentEntryCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _RecentEntryCard({required this.record});

  StatusBadgeState _parseStatus(String? s) {
    switch (s) {
      case 'verified':
        return StatusBadgeState.confirmed;
      case 'rejected':
        return StatusBadgeState.disputed;
      default:
        return StatusBadgeState.pending;
    }
  }

  IconData _workTypeIcon(String? workType) {
    switch (workType?.toLowerCase()) {
      case 'construction':
        return Icons.construction_rounded;
      case 'painting':
        return Icons.format_paint_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'carpentry':
        return Icons.handyman_rounded;
      default:
        return Icons.currency_rupee_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = record['amount'] ?? 0;
    final employer = record['employer_name'] ?? '-';
    final workType = record['work_type'] ?? '';
    final date = record['date'] ?? '';
    final status = record['status'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          // Work type icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _workTypeIcon(workType),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      workType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(state: _parseStatus(status)),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  BOTTOM NAV ITEM with orange active pill
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color:
                    isActive ? AppColors.primary : AppColors.darkTextTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? AppColors.primary : AppColors.darkTextTertiary,
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            // Orange pill indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(top: 4),
              width: isActive ? 22 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
