import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';
import '../../widgets/sgap_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLang = 'हिंदी';
  bool _notifyIncome = true;
  bool _notifyLoans = true;
  bool _notifySchemes = false;

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'सेटिंग्स'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Language
          _sectionTitle('भाषा', hindi),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _selectedLang, isExpanded: true, dropdownColor: AppColors.darkCard,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: hindi.copyWith(color: Colors.white, fontSize: 16),
              items: ['हिंदी', 'English', 'தமிழ்', 'తెలుగు', 'ಕನ್ನಡ'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedLang = v); },
            )),
          ),

          const SizedBox(height: 28),
          _sectionTitle('सूचनाएं', hindi),
          const SizedBox(height: 10),
          _toggle('कमाई अपडेट', 'नई एंट्री और सत्यापन', _notifyIncome, (v) => setState(() => _notifyIncome = v), hindi),
          _toggle('लोन अपडेट', 'ऑफर और EMI रिमाइंडर', _notifyLoans, (v) => setState(() => _notifyLoans = v), hindi),
          _toggle('योजना अपडेट', 'नई सरकारी योजनाएं', _notifySchemes, (v) => setState(() => _notifySchemes = v), hindi),

          const SizedBox(height: 28),
          _sectionTitle('डेटा', hindi),
          const SizedBox(height: 10),
          _actionTile(Icons.download_rounded, 'डेटा एक्सपोर्ट करो', 'अपनी सारी जानकारी डाउनलोड करो', AppColors.info, () {
            _snack('डेटा एक्सपोर्ट जल्द आ रहा है');
          }, hindi),

          const SizedBox(height: 28),
          // Danger zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('⚠️ खतरे का क्षेत्र', style: hindi.copyWith(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(),
                  icon: const Icon(Icons.delete_forever_rounded, size: 20),
                  label: Text('अकाउंट डिलीट करो', style: hindi.copyWith(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )),
            ]),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, TextStyle hindi) {
    return Text(t, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18));
  }

  Widget _toggle(String title, String sub, bool val, ValueChanged<bool> onChanged, TextStyle hindi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: SwitchListTile(
        title: Text(title, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: Text(sub, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
        value: val, onChanged: onChanged,
        activeColor: AppColors.primary,
        inactiveThumbColor: AppColors.darkBorder,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String sub, Color color, VoidCallback onTap, TextStyle hindi) {
    return Container(
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      child: ListTile(
        leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: hindi.copyWith(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: Text(sub, style: hindi.copyWith(color: AppColors.darkTextTertiary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
        onTap: onTap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showDeleteDialog() {
    final hindi = GoogleFonts.notoSansDevanagari();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('अकाउंट डिलीट?', style: hindi.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
      content: Text('क्या आप वाकई अपना अकाउंट हटाना चाहते हैं? यह कार्यवाही पलटी नहीं जा सकती।', style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('रद्द करो', style: hindi.copyWith(color: AppColors.darkTextSecondary))),
        TextButton(onPressed: () { Navigator.pop(ctx); _snack('अकाउंट डिलीट जल्द उपलब्ध होगा'); }, child: Text('हां, हटाओ', style: hindi.copyWith(color: AppColors.error, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.notoSansDevanagari()), backgroundColor: AppColors.darkCard, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}
