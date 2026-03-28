import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/sgap_app_bar.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});
  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int _selectedTab = 0;
  List<Map<String, dynamic>> _allSchemes = [];
  late AnimationController _fadeCtrl;

  final _tabs = [
    {'label': 'सभी', 'category': 'all'},
    {'label': 'बीमा', 'category': 'insurance'},
    {'label': 'पेंशन', 'category': 'pension'},
    {'label': 'स्वास्थ्य', 'category': 'health'},
    {'label': 'पहचान', 'category': 'identity'},
    {'label': 'आवास', 'category': 'housing'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    final data = await MockApiService.instance.getSchemes();
    if (!mounted) return;
    setState(() {
      _allSchemes = ((data['schemes'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>();
      _isLoading = false;
    });
    _fadeCtrl.forward();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 0) return _allSchemes;
    final cat = _tabs[_selectedTab]['category']!;
    return _allSchemes.where((s) => s['category'] == cat).toList();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'सरकारी योजनाएं'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: Column(children: [
                // Category tabs
                SizedBox(height: 50, child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _tabs.length,
                  itemBuilder: (ctx, i) {
                    final sel = i == _selectedTab;
                    return Padding(padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedTab = i); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(20),
                            border: sel ? null : Border.all(color: AppColors.darkBorder, width: 0.5),
                          ),
                          child: Center(child: Text(_tabs[i]['label']!, style: hindi.copyWith(color: sel ? Colors.white : AppColors.darkTextSecondary, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, fontSize: 13))),
                        ),
                      ),
                    );
                  },
                )),
                // Schemes list
                Expanded(child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final scheme = _filtered[i];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 350 + (i * 80)),
                      curve: Curves.easeOut,
                      builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
                      child: _SchemeCard(scheme: scheme),
                    );
                  },
                )),
              ]),
            ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final Map<String, dynamic> scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final name = scheme['name'] as String? ?? '';
    final desc = scheme['description'] as String? ?? '';
    final benefit = scheme['benefit'] as String? ?? '';
    final eligibility = scheme['eligibility'] as String? ?? '';
    final applied = scheme['applied'] as bool? ?? false;
    final link = scheme['link'] as String? ?? '';
    final isEligible = eligibility == 'eligible';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEligible ? AppColors.success.withValues(alpha: 0.2) : AppColors.darkBorder, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
          if (isEligible && !applied)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('पात्र ✓', style: hindi.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11))),
          if (applied)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('लागू ✓', style: hindi.copyWith(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 11))),
        ]),
        const SizedBox(height: 8),
        Text(desc, style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        // Benefit badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Text('💰 $benefit', style: hindi.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 40,
          child: ElevatedButton(
            onPressed: () {
              if (link.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$link पर जाएं', style: GoogleFonts.notoSansDevanagari()),
                  backgroundColor: AppColors.darkCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: applied ? AppColors.darkBorder : AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            child: Text(applied ? 'पहले से लागू' : 'अभी अप्लाई करो', style: hindi.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          )),
      ]),
    );
  }
}
