import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/sgap_app_bar.dart';

class LoanOffersScreen extends StatefulWidget {
  const LoanOffersScreen({super.key});
  @override
  State<LoanOffersScreen> createState() => _LoanOffersScreenState();
}

class _LoanOffersScreenState extends State<LoanOffersScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _offers = [];
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final data = await MockApiService.instance.applyLoan({'amount': 50000, 'purpose': 'general'});
    if (!mounted) return;
    setState(() {
      _offers = ((data['offers'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
      _isLoading = false;
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'लोन ऑफर'),
      body: _isLoading ? _buildLoadingState(hindi) : FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: _buildContent(hindi),
      ),
    );
  }

  Widget _buildLoadingState(TextStyle hindi) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
      const SizedBox(height: 20),
      Text('OCEN से ऑफर ला रहे हैं...', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 15)),
      const SizedBox(height: 8),
      Text('कृपया प्रतीक्षा करें', style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 13)),
    ]));
  }

  Widget _buildContent(TextStyle hindi) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        // Header
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.darkCard]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('आपके लिए ${_offers.length} ऑफर हैं!', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              Text('सबसे अच्छा चुनो', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        // Offer Cards
        ...List.generate(_offers.length, (i) {
          final offer = _offers[i];
          final isBest = i == 2; // Grameen has lowest interest
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (i * 150)),
            curve: Curves.easeOut,
            builder: (ctx, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child)),
            child: _OfferCard(offer: offer, isBest: isBest, onAccept: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pushNamed('/loan-success');
            }),
          );
        }),
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final bool isBest;
  final VoidCallback onAccept;
  const _OfferCard({required this.offer, required this.isBest, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lender = offer['lender'] as String? ?? '';
    final amount = offer['amount'] as int? ?? 0;
    final rate = offer['interest_rate'] as double? ?? 0;
    final emi = offer['emi'] as int? ?? 0;
    final tenure = offer['tenure_months'] as int? ?? 0;
    final approval = offer['approval_time'] as String? ?? '';

    return Container(
      width: double.infinity, margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isBest ? AppColors.success.withValues(alpha: 0.5) : AppColors.darkBorder, width: isBest ? 1.5 : 0.5),
        boxShadow: isBest ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))] : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_rounded, color: AppColors.info, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Text(lender, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
          if (isBest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('सबसे अच्छा', style: hindi.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11)),
            ),
        ]),
        const SizedBox(height: 16),
        // Stats
        Row(children: [
          _OfferStat('राशि', '₹${(amount ~/ 1000)}K', AppColors.primary),
          _OfferStat('ब्याज', '${rate.toStringAsFixed(1)}%', AppColors.warning),
          _OfferStat('EMI', '₹$emi', Colors.white),
          _OfferStat('अवधि', '$tenure महीने', AppColors.secondary),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.access_time_rounded, size: 14, color: AppColors.darkTextTertiary),
          const SizedBox(width: 4),
          Text('अप्रूवल: $approval', style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: isBest ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Text('यह ऑफर चुनो', style: hindi.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
      ]),
    );
  }
}

class _OfferStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _OfferStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.notoSansDevanagari(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
    const SizedBox(height: 2),
    Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 11)),
  ]));
}
