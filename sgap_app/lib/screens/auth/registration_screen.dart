import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Naya
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart'; // Naya
import '../../core/localization/app_translations.dart'; // Naya

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});
  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _aadhaarController = TextEditingController();
  String? _selectedWorkType;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  // Ab labels ki jagah translation keys use kar rahe hain
  final List<Map<String, String>> _workTypes = const [
    {'value': 'mason', 'key': 'wt_mason', 'emoji': '🧱'},
    {'value': 'domestic', 'key': 'wt_domestic', 'emoji': '🏠'},
    {'value': 'delivery', 'key': 'wt_delivery', 'emoji': '📦'},
    {'value': 'driver', 'key': 'wt_driver', 'emoji': '🚗'},
    {'value': 'shop', 'key': 'wt_shop', 'emoji': '🏪'},
    {'value': 'factory', 'key': 'wt_factory', 'emoji': '🏭'},
    {'value': 'farming', 'key': 'wt_farming', 'emoji': '🌾'},
    {'value': 'other', 'key': 'wt_other', 'emoji': '💼'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() { _nameController.dispose(); _cityController.dispose(); _aadhaarController.dispose(); _animController.dispose(); super.dispose(); }

  Future<void> _onRegister(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, 'work_type_req'), style: const TextStyle(fontSize: 16)), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = await SecureStorage.instance.getPhone();
      final result = await MockApiService.instance.registerWorker({
        'name': _nameController.text.trim(), 'phone': phone ?? '', 'city': _cityController.text.trim(),
        'occupation': _selectedWorkType, 'aadhaar': _aadhaarController.text.trim(),
        'language': lang == 'English' ? 'en' : 'hi',
      });

      if (!mounted) return;
      await SecureStorage.instance.saveWorkerProfile(result);
      await SecureStorage.instance.setOnboarded();

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/welcome', arguments: _nameController.text.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, 'reg_error'), style: const TextStyle(fontSize: 16)), backgroundColor: AppColors.error));
    }
  }

  void _onVoiceName(String lang) {
    setState(() => _nameController.text = 'रमेश कुमार');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, 'voice_name_snack'), style: const TextStyle(fontSize: 16)), backgroundColor: AppColors.primary, duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider); // Language check

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 48),
                Row(children: const [_ProgressDot(active: true), _ProgressLine(active: true), _ProgressDot(active: true), _ProgressLine(active: true), _ProgressDot(active: true), _ProgressLine(active: false), _ProgressDot(active: false)]),
                const SizedBox(height: 32),
                Text(tr(lang, 'fill_details'), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(tr(lang, 'profile_info_sub'), style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary)),
                const SizedBox(height: 36),
                Text(tr(lang, 'name_label'), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                      decoration: InputDecoration(hintText: tr(lang, 'name_hint'), hintStyle: TextStyle(color: AppColors.darkTextTertiary.withValues(alpha: 0.6)), prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.darkTextTertiary), filled: true, fillColor: AppColors.darkSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2))),
                      validator: (v) => v == null || v.trim().isEmpty ? tr(lang, 'name_req') : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(onTap: () => _onVoiceName(lang), child: Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.4))), child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 26))),
                ]),
                const SizedBox(height: 22),
                Text(tr(lang, 'city_label'), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cityController, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                  decoration: InputDecoration(hintText: tr(lang, 'city_hint'), hintStyle: TextStyle(color: AppColors.darkTextTertiary.withValues(alpha: 0.6)), prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.darkTextTertiary), filled: true, fillColor: AppColors.darkSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2))),
                  validator: (v) => v == null || v.trim().isEmpty ? tr(lang, 'city_req') : null,
                ),
                const SizedBox(height: 22),
                Text(tr(lang, 'work_type_label'), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedWorkType,
                  decoration: InputDecoration(hintText: tr(lang, 'select_hint'), hintStyle: TextStyle(color: AppColors.darkTextTertiary.withValues(alpha: 0.6)), prefixIcon: const Icon(Icons.work_outline_rounded, color: AppColors.darkTextTertiary), filled: true, fillColor: AppColors.darkSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2))),
                  dropdownColor: AppColors.darkCard, icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.darkTextSecondary), style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                  items: _workTypes.map((w) => DropdownMenuItem(value: w['value'], child: Text('${w['emoji']}  ${tr(lang, w['key']!)}'))).toList(),
                  onChanged: (v) => setState(() => _selectedWorkType = v), validator: (v) => v == null ? tr(lang, 'work_type_req') : null,
                ),
                const SizedBox(height: 22),
                Text(tr(lang, 'aadhaar_label'), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _aadhaarController, keyboardType: TextInputType.number, maxLength: 12, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, letterSpacing: 2),
                  decoration: InputDecoration(hintText: 'XXXX XXXX XXXX', hintStyle: TextStyle(color: AppColors.darkTextTertiary.withValues(alpha: 0.6), letterSpacing: 2), prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.darkTextTertiary), counterText: '', filled: true, fillColor: AppColors.darkSurface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkBorder)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2))),
                ),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.shield_outlined, color: AppColors.darkTextTertiary, size: 16), const SizedBox(width: 6), Expanded(child: Text(tr(lang, 'aadhaar_help'), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextTertiary)))]),
                const SizedBox(height: 40),
                SizedBox(width: double.infinity, height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _onRegister(lang),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: _isLoading ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : Text(tr(lang, 'done_btn'), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                  )),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool active; const _ProgressDot({required this.active});
  @override Widget build(BuildContext context) => Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primary : AppColors.darkBorder, border: Border.all(color: active ? AppColors.primary : AppColors.darkBorder, width: 2)));
}

class _ProgressLine extends StatelessWidget {
  final bool active; const _ProgressLine({required this.active});
  @override Widget build(BuildContext context) => Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.darkBorder, borderRadius: BorderRadius.circular(2))));
}