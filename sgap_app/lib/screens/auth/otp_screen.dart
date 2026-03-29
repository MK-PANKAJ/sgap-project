import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart';
import '../../core/localization/app_translations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false, _isVerified = false, _canResend = false;
  String? _errorMessage;
  int _resendCountdown = 30;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false; _resendCountdown = 30; _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() { _resendCountdown--; if (_resendCountdown <= 0) { _canResend = true; timer.cancel(); } });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp(String lang) async {
    if (_otp.length != 6 || _isLoading) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final result = await MockApiService.instance.verifyOtp('+91${widget.phoneNumber}', _otp);
      if (!mounted) return;

      if (result['success'] == false) {
        setState(() { _isLoading = false; _errorMessage = result['message'] as String? ?? tr(lang, 'wrong_otp'); });
        _clearFields(); return;
      }

      final token = result['token'] as String?;
      if (token != null) await SecureStorage.instance.saveToken(token);

      final user = result['user'] as Map<String, dynamic>?;
      if (user != null) await SecureStorage.instance.saveWorkerProfile(user);

      setState(() { _isLoading = false; _isVerified = true; });
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final isNewUser = result['is_new_user'] as bool? ?? true;
      if (isNewUser) Navigator.of(context).pushReplacementNamed('/registration');
      else Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = tr(lang, 'something_wrong'); });
    }
  }

  void _clearFields() { for (final c in _controllers) { c.clear(); } _focusNodes[0].requestFocus(); }

  Future<void> _onResend(String lang) async {
    if (!_canResend) return;
    _startResendTimer();
    try {
      await MockApiService.instance.sendOtp('+91${widget.phoneNumber}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, 'otp_resent'), style: const TextStyle(fontSize: 16)), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)));
    } catch (_) {}
  }

  @override
  void dispose() { _timer?.cancel(); _animController.dispose(); for (final c in _controllers) { c.dispose(); } for (final f in _focusNodes) { f.dispose(); } super.dispose(); }

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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),
              GestureDetector(onTap: () => Navigator.of(context).pop(), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22))),
              const SizedBox(height: 32),
              Text(tr(lang, 'enter_otp'), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              RichText(text: TextSpan(style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary), children: [TextSpan(text: tr(lang, 'code_sent_to')), TextSpan(text: '+91 ${widget.phoneNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))])),
              const SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (index) {
                final hasValue = _controllers[index].text.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200), width: 50, height: 60,
                  decoration: BoxDecoration(color: _isVerified ? AppColors.success.withValues(alpha: 0.15) : hasValue ? AppColors.primary.withValues(alpha: 0.1) : AppColors.darkSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _isVerified ? AppColors.success : hasValue ? AppColors.primary : AppColors.darkBorder, width: hasValue || _isVerified ? 2 : 1)),
                  child: TextFormField(
                    controller: _controllers[index], focusNode: _focusNodes[index], textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1,
                    style: theme.textTheme.headlineSmall?.copyWith(color: _isVerified ? AppColors.success : Colors.white, fontWeight: FontWeight.w700), inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: '', contentPadding: EdgeInsets.zero, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
                      else if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                      if (_otp.length == 6) _verifyOtp(lang);
                    },
                  ),
                );
              })),
              const SizedBox(height: 20),
              if (_errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const Icon(Icons.error_outline, color: AppColors.error, size: 18), const SizedBox(width: 6), Expanded(child: Text(_errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error)))])),
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withValues(alpha: 0.3))), child: Row(children: [const Icon(Icons.info_outline, color: AppColors.warning, size: 18), const SizedBox(width: 8), Text(tr(lang, 'demo_otp_hint'), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w500))])),
              const SizedBox(height: 24),
              Center(child: _canResend ? TextButton.icon(onPressed: () => _onResend(lang), icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20), label: Text(tr(lang, 'resend_otp_btn'), style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600))) : Text('${tr(lang, 'resend_in')} $_resendCountdown ${tr(lang, 'seconds')}', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkTextTertiary))),
              const Spacer(),
              SizedBox(width: double.infinity, height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading || _otp.length != 6 ? null : () => _verifyOtp(lang),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.darkBorder, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: _isLoading ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : _isVerified ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.white, size: 22), const SizedBox(width: 8), Text(tr(lang, 'verified_check'), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700))]) : Text(tr(lang, 'verify_btn'), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                )),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }
}