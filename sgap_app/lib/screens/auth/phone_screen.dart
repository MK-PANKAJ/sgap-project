import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';

/// Phone number input for OTP-based login.
///
/// - Hindi title "अपना नंबर डालो"
/// - +91 prefix, 10-digit input, WhatsApp-style number keyboard
/// - Calls [MockApiService.sendOtp] on tap
/// - Hindi validation errors
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'फ़ोन नंबर डालना ज़रूरी है';
    }
    if (value.length != 10) {
      return '10 अंकों का सही नंबर डालें';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'सही भारतीय मोबाइल नंबर डालें';
    }
    return null;
  }

  Future<void> _onSendOtp() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result =
          await MockApiService.instance.sendOtp('+91${_phoneController.text}');
      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show demo OTP hint
      if (result.containsKey('demo_otp')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Demo OTP: ${result['demo_otp']}',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      Navigator.of(context).pushNamed(
        '/otp',
        arguments: _phoneController.text,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'OTP भेजने में समस्या हुई। कृपया पुनः प्रयास करें।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Back button ──
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Title ──
                  Text(
                    'अपना नंबर डालो',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'हम आपको OTP भेजेंगे',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Phone input ──
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      autofocus: true,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: _validatePhone,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 18, right: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🇮🇳',
                                style: TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+91',
                                style:
                                    theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.darkTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 28,
                                color: AppColors.darkBorder,
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        hintText: '98765 43210',
                        hintStyle:
                            theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkTextTertiary
                              .withValues(alpha: 0.4),
                          letterSpacing: 3,
                        ),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                      ),
                    ),
                  ),

                  // ── Validation error (external) ──
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── Helper text ──
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.darkTextTertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'आपकी जानकारी सुरक्षित है',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── CTA ──
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onSendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'OTP भेजो',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.send_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
