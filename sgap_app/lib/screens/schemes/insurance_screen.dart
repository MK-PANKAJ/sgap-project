import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/sgap_app_bar.dart';
import '../../widgets/coming_soon_card.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});
  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _plans = [];
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final data = await MockApiService.instance.getInsurance();
    if (!mounted) return;
    setState(() {
      _plans = ((data['plans'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
      _isLoading = false;
    });
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  IconData _planIcon(String type) {
    switch (type) {
      case 'life': return Icons.favorite_rounded;
      case 'accident': return Icons.shield_rounded;
      case 'health': return Icons.local_hospital_rounded;
      default: return Icons.security_rounded;
    }
  }

  Color _planColor(String type) {
    switch (type) {
      case 'life': return AppColors.error;
      case 'accident': return AppColors.warning;
      case 'health': return AppColors.success;
      default: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'बीमा योजनाएं'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Header
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.secondary.withValues(alpha: 0.1), AppColors.darkCard]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      const Text('🛡️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('अपने परिवार को सुरक्षित करो', style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('सस्ती बीमा योजनाएं', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 13)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  // Plan cards
                  ...List.generate(_plans.length, (i) {
                    final plan = _plans[i];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + (i * 120)),
                      curve: Curves.easeOut,
                      builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child)),
                      child: _InsurancePlanCard(plan: plan, icon: _planIcon(plan['type'] as String? ?? ''), color: _planColor(plan['type'] as String? ?? '')),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _InsurancePlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final IconData icon;
  final Color color;
  const _InsurancePlanCard({required this.plan, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final name = plan['name'] as String? ?? '';
    final premium = plan['premium_monthly'] as int? ?? 0;
    final coverHindi = plan['cover_hindi'] as String? ?? '';
    final features = (plan['features'] as List<dynamic>?)?.cast<String>() ?? [];
    final popular = plan['popular'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: popular ? color.withValues(alpha: 0.4) : AppColors.darkBorder, width: popular ? 1.5 : 0.5),
        boxShadow: popular ? [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))] : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            Text(coverHindi, style: hindi.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ])),
          if (popular)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('लोकप्रिय', style: hindi.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 11))),
        ]),
        const SizedBox(height: 14),
        // Premium
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.darkBackground.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('प्रीमियम: ', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 14)),
            Text('₹$premium/महीना', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
        ),
        const SizedBox(height: 14),
        // Features
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(child: Text(f, style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 12, height: 1.4))),
          ]),
        )),
        const SizedBox(height: 14),
        // Enroll button
        SizedBox(width: double.infinity, height: 44,
          child: ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.darkCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: const ComingSoonCard(featureName: 'बीमा नामांकन', phaseBadgeText: 'Phase 2', icon: Icons.shield_rounded),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ठीक है', style: hindi.copyWith(color: AppColors.primary)))],
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Text('नामांकन करो', style: hindi.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
          )),
      ]),
    );
  }
}
