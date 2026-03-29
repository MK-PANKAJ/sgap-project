import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart';
import '../../core/localization/app_translations.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() { _phoneController.dispose(); _animController.dispose(); super.dispose(); }

  String? _validatePhone(String? value, String lang) {
    if (value == null || value.isEmpty) return tr(lang, 'val_phone_req');
    if (value.length != 10) return tr(lang, 'val_phone_10');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return tr(lang, 'val_phone_valid');
    return null;
  }

  Future<void> _onSendOtp(String lang) async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await MockApiService.instance.sendOtp('+91${_phoneController.text}');
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.containsKey('demo_otp')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo OTP: ${result['demo_otp']}', style: const TextStyle(fontSize: 16)), backgroundColor: AppColors.primary, duration: const Duration(seconds: 3)));
      }
      Navigator.of(context).pushNamed('/otp', arguments: _phoneController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = tr(lang, 'otp_send_error'); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider); 

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 48),
                GestureDetector(onTap: () => Navigator.of(context).pop(), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22))),
                const SizedBox(height: 32),
                Text(tr(lang, 'enter_phone'), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(tr(lang, 'will_send_otp'), style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary)),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
                  child: TextFormField(
                    controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 10, autofocus: true,
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.w600),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _validatePhone(v, lang),
                    decoration: InputDecoration(
                      prefixIcon: Padding(padding: const EdgeInsets.only(left: 18, right: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('🇮🇳', style: TextStyle(fontSize: 22)), const SizedBox(width: 8), Text('+91', style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w600)), const SizedBox(width: 10), Container(width: 1, height: 28, color: AppColors.darkBorder)])),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0), hintText: '98765 43210',
                      hintStyle: theme.textTheme.headlineSmall?.copyWith(color: AppColors.darkTextTertiary.withValues(alpha: 0.4), letterSpacing: 3), counterText: '', contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, errorBorder: InputBorder.none, focusedErrorBorder: InputBorder.none, errorStyle: const TextStyle(fontSize: 0, height: 0),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[const SizedBox(height: 12), Row(children: [const Icon(Icons.error_outline, color: AppColors.error, size: 18), const SizedBox(width: 6), Expanded(child: Text(_errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error)))])],
                const SizedBox(height: 14),
                Row(children: [Icon(Icons.lock_outline_rounded, color: AppColors.darkTextTertiary, size: 16), const SizedBox(width: 6), Text(tr(lang, 'info_secure'), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkTextTertiary))]),
                const Spacer(),
                SizedBox(width: double.infinity, height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _onSendOtp(lang),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: _isLoading ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(tr(lang, 'send_otp_btn'), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)), const SizedBox(width: 10), const Icon(Icons.send_rounded, size: 20)]),
                  )),
                const SizedBox(height: 28),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}