import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../widgets/sgap_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _profile = {};
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await MockApiService.instance.getMe();
    if (!mounted) return;
    setState(() { _profile = data; _isLoading = false; });
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _logout() async {
    await SecureStorage.instance.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/language', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'प्रोफ़ाइल', showBack: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const SizedBox(height: 24),
                  _buildProfileHeader(hindi),
                  const SizedBox(height: 24),
                  _buildStats(hindi),
                  const SizedBox(height: 24),
                  _buildAadhaarStatus(hindi),
                  const SizedBox(height: 24),
                  _buildMenuItems(hindi),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight}) hindi) {
    final name = _profile['name'] as String? ?? 'अज्ञात';
    final city = _profile['city'] as String? ?? '';
    final occupation = _profile['occupation'] as String? ?? '';
    final initials = name.isNotEmpty ? name[0] : '?';

    return Column(children: [
      // Avatar
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primary.withValues(alpha: 0.35), AppColors.primaryDark.withValues(alpha: 0.15)]),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 3),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Center(child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 36))),
      ),
      const SizedBox(height: 16),
      Text(name, style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22)),
      const SizedBox(height: 4),
      Text('$city • $occupation', style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextSecondary, fontSize: 14)),
    ]);
  }

  Widget _buildStats(TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight}) hindi) {
    final totalIncome = _profile['total_income_logged'] as int? ?? 0;
    final memberSince = _profile['member_since'] as String? ?? '';

    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: Row(children: [
        _StatItem('कुल कमाई', '₹${(totalIncome / 1000).toStringAsFixed(0)}K', AppColors.primary),
        _divider(),
        _StatItem('पक्की आय', '₹${((totalIncome * 0.85) / 1000).toStringAsFixed(0)}K', AppColors.success),
        _divider(),
        _StatItem('मालिक', '8', AppColors.info),
        _divider(),
        _StatItem('दिन', _daysSince(memberSince), AppColors.secondary),
      ]),
    );
  }

  Widget _buildAadhaarStatus(TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight}) hindi) {
    final verified = _profile['aadhaar_verified'] as bool? ?? false;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verified ? AppColors.success.withValues(alpha: 0.06) : AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: verified ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: (verified ? AppColors.success : AppColors.warning).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(verified ? Icons.verified_rounded : Icons.warning_amber_rounded, color: verified ? AppColors.success : AppColors.warning, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('आधार सत्यापन', style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(verified ? 'सत्यापित ✓' : 'सत्यापन बाकी है', style: GoogleFonts.notoSansDevanagari(color: verified ? AppColors.success : AppColors.warning, fontSize: 13)),
        ])),
        if (!verified)
          TextButton(onPressed: () {}, child: Text('करो →', style: GoogleFonts.notoSansDevanagari(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildMenuItems(TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight}) hindi) {
    final items = [
      _MenuItem(Icons.settings_rounded, 'सेटिंग्स', '/settings'),
      _MenuItem(Icons.language_rounded, 'भाषा बदलो', '/language'),
      _MenuItem(Icons.map_rounded, 'रोडमैप', '/roadmap'),
      _MenuItem(Icons.help_outline_rounded, 'मदद', '/help'),
    ];

    return Column(children: [
      ...items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
        child: ListTile(
          leading: Container(width: 38, height: 38,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: AppColors.primary, size: 20)),
          title: Text(item.label, style: GoogleFonts.notoSansDevanagari(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
          onTap: () => Navigator.of(context).pushNamed(item.route),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      )),
      const SizedBox(height: 8),
      // Logout
      Container(
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
        child: ListTile(
          leading: Container(width: 38, height: 38,
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20)),
          title: Text('लॉगआउट', style: GoogleFonts.notoSansDevanagari(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 15)),
          onTap: _logout,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ]);
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.darkBorder.withValues(alpha: 0.5));

  String _daysSince(String dateStr) {
    if (dateStr.isEmpty) return '0';
    try {
      final d = DateTime.parse(dateStr);
      return '${DateTime.now().difference(d).inDays}';
    } catch (_) { return '0'; }
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.notoSansDevanagari(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
    const SizedBox(height: 2),
    Text(label, style: GoogleFonts.notoSansDevanagari(color: AppColors.darkTextTertiary, fontSize: 11)),
  ]));
}

class _MenuItem {
  final IconData icon;
  final String label, route;
  const _MenuItem(this.icon, this.label, this.route);
}
