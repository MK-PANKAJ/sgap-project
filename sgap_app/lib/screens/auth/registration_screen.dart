import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/mock_api_service.dart';

/// Worker registration screen — profile creation for new users.
///
/// Fields: नाम, शहर, काम का प्रकार (dropdown), आधार नंबर (optional)
/// Includes a mic button next to name for voice input.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _aadhaarController = TextEditingController();
  String? _selectedWorkType;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final List<_WorkType> _workTypes = const [
    _WorkType(value: 'mason', label: 'मिस्त्री', emoji: '🧱'),
    _WorkType(value: 'domestic', label: 'घर का काम', emoji: '🏠'),
    _WorkType(value: 'delivery', label: 'डिलीवरी', emoji: '📦'),
    _WorkType(value: 'driver', label: 'ड्राइवर', emoji: '🚗'),
    _WorkType(value: 'shop', label: 'दुकान', emoji: '🏪'),
    _WorkType(value: 'factory', label: 'फैक्ट्री', emoji: '🏭'),
    _WorkType(value: 'farming', label: 'खेती', emoji: '🌾'),
    _WorkType(value: 'other', label: 'अन्य', emoji: '💼'),
  ];

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
    _nameController.dispose();
    _cityController.dispose();
    _aadhaarController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया काम का प्रकार चुनें',
              style: TextStyle(fontSize: 16)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phone = await SecureStorage.instance.getPhone();
      final result = await MockApiService.instance.registerWorker({
        'name': _nameController.text.trim(),
        'phone': phone ?? '',
        'city': _cityController.text.trim(),
        'occupation': _selectedWorkType,
        'aadhaar': _aadhaarController.text.trim(),
        'language': await SecureStorage.instance.getLanguage() ?? 'hi',
      });

      if (!mounted) return;

      // Save the profile
      await SecureStorage.instance.saveWorkerProfile(result);
      await SecureStorage.instance.setOnboarded();

      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/welcome',
        arguments: _nameController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('रजिस्ट्रेशन में समस्या हुई। कृपया पुनः प्रयास करें।',
              style: TextStyle(fontSize: 16)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onVoiceName() {
    // Simulate voice input for demo
    setState(() {
      _nameController.text = 'रमेश कुमार';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 आवाज़ से लिखा: रमेश कुमार',
            style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Progress indicator ──
                  Row(
                    children: [
                      _ProgressDot(active: true),
                      _ProgressLine(active: true),
                      _ProgressDot(active: true),
                      _ProgressLine(active: true),
                      _ProgressDot(active: true),
                      _ProgressLine(active: false),
                      _ProgressDot(active: false),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Title ──
                  Text(
                    'अपनी जानकारी भरो',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'यह जानकारी आपकी प्रोफ़ाइल के लिए है',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ━━ नाम (with mic button) ━━
                  Text(
                    'नाम *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'अपना पूरा नाम लिखें',
                            hintStyle: TextStyle(
                              color: AppColors.darkTextTertiary
                                  .withValues(alpha: 0.6),
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.darkTextTertiary,
                            ),
                            filled: true,
                            fillColor: AppColors.darkSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.darkBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.darkBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'नाम डालना ज़रूरी है'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Mic button
                      GestureDetector(
                        onTap: _onVoiceName,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ━━ शहर ━━
                  Text(
                    'शहर *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'जैसे: दिल्ली, मुंबई, लखनऊ',
                      hintStyle: TextStyle(
                        color:
                            AppColors.darkTextTertiary.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.location_city_rounded,
                        color: AppColors.darkTextTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'शहर का नाम डालें'
                            : null,
                  ),

                  const SizedBox(height: 22),

                  // ━━ काम का प्रकार (dropdown) ━━
                  Text(
                    'काम का प्रकार *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedWorkType,
                    decoration: InputDecoration(
                      hintText: 'चुनें',
                      hintStyle: TextStyle(
                        color:
                            AppColors.darkTextTertiary.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.work_outline_rounded,
                        color: AppColors.darkTextTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    dropdownColor: AppColors.darkCard,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.darkTextSecondary),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                    items: _workTypes
                        .map(
                          (w) => DropdownMenuItem(
                            value: w.value,
                            child: Text('${w.emoji}  ${w.label}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedWorkType = v),
                    validator: (v) =>
                        v == null ? 'काम का प्रकार चुनें' : null,
                  ),

                  const SizedBox(height: 22),

                  // ━━ आधार नंबर (optional) ━━
                  Text(
                    'आधार नंबर (वैकल्पिक)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _aadhaarController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'XXXX XXXX XXXX',
                      hintStyle: TextStyle(
                        color:
                            AppColors.darkTextTertiary.withValues(alpha: 0.6),
                        letterSpacing: 2,
                      ),
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.darkTextTertiary,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Helper hint
                  Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          color: AppColors.darkTextTertiary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'आधार देने से आपका ट्रस्ट स्कोर 50 अंक बढ़ेगा',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.darkTextTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ── CTA ──
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onRegister,
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
                          : Text(
                              'हो गया! ✓',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Progress indicator widgets ──

class _ProgressDot extends StatelessWidget {
  final bool active;
  const _ProgressDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.darkBorder,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.darkBorder,
          width: 2,
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final bool active;
  const _ProgressLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.darkBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Work type model ──

class _WorkType {
  final String value;
  final String label;
  final String emoji;
  const _WorkType({
    required this.value,
    required this.label,
    required this.emoji,
  });
}
