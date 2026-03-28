import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/sgap_app_bar.dart';

/// ─────────────────────────────────────────────────────────────────
///  VOICE LOGGER — Speak to log income
///
///  States:
///  1. IDLE    → Big mic button + instruction text
///  2. RECORD  → Pulsing rings + waveform animation
///  3. PROCESS → "समझ रहे हैं..." with processing indicator
///  4. RESULT  → Editable card (amount, employer, type, date)
///  5. SAVED   → Success animation "हो गया! ✓"
/// ─────────────────────────────────────────────────────────────────

enum _VoiceState { idle, recording, processing, result, saved }

class VoiceLoggerScreen extends StatefulWidget {
  const VoiceLoggerScreen({super.key});

  @override
  State<VoiceLoggerScreen> createState() => _VoiceLoggerScreenState();
}

class _VoiceLoggerScreenState extends State<VoiceLoggerScreen>
    with TickerProviderStateMixin {
  _VoiceState _state = _VoiceState.idle;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _processingController;
  late AnimationController _successController;

  // Result data (editable)
  final _amountController = TextEditingController();
  final _employerController = TextEditingController();
  String _selectedWorkType = 'Construction';
  DateTime _selectedDate = DateTime.now();

  final List<String> _workTypes = [
    'Construction',
    'Painting',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Masonry',
    'Labour',
    'Driving',
    'Cleaning',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _processingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _processingController.dispose();
    _successController.dispose();
    _amountController.dispose();
    _employerController.dispose();
    super.dispose();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  STATE TRANSITIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _startRecording() {
    HapticFeedback.mediumImpact();
    setState(() => _state = _VoiceState.recording);
    _pulseController.repeat();
  }

  void _stopRecording() async {
    HapticFeedback.lightImpact();
    _pulseController.stop();
    setState(() => _state = _VoiceState.processing);

    // Simulate Bhashini processing
    final result = await MockApiService.instance.processVoiceLog('', 'hi');

    if (!mounted) return;

    _amountController.text = '${result['amount'] ?? 800}';
    _employerController.text = result['employer_name'] ?? '';
    _selectedWorkType = result['work_type'] ?? 'Construction';

    setState(() => _state = _VoiceState.result);
  }

  void _saveEntry() async {
    HapticFeedback.mediumImpact();
    setState(() => _state = _VoiceState.processing);

    await MockApiService.instance.confirmEntry({
      'amount': int.tryParse(_amountController.text) ?? 800,
      'employer_name': _employerController.text,
      'work_type': _selectedWorkType,
      'date': _selectedDate.toIso8601String().split('T').first,
    });

    if (!mounted) return;

    setState(() => _state = _VoiceState.saved);
    _successController.forward(from: 0);

    // Auto-pop after success animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _resetToIdle() {
    HapticFeedback.lightImpact();
    _amountController.clear();
    _employerController.clear();
    setState(() {
      _state = _VoiceState.idle;
      _selectedWorkType = 'Construction';
      _selectedDate = DateTime.now();
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  BUILD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const SgapAppBar(title: 'आवाज़ से लॉग करो'),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildCurrentState(theme),
        ),
      ),
    );
  }

  Widget _buildCurrentState(ThemeData theme) {
    switch (_state) {
      case _VoiceState.idle:
        return _buildIdleState(theme);
      case _VoiceState.recording:
        return _buildRecordingState(theme);
      case _VoiceState.processing:
        return _buildProcessingState(theme);
      case _VoiceState.result:
        return _buildResultState(theme);
      case _VoiceState.saved:
        return _buildSavedState(theme);
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  IDLE STATE — Big mic button + instructions
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildIdleState(ThemeData theme) {
    return Padding(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Instruction
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                const Text('💡', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                Text(
                  'बोलो —',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '"आज सुरेश भाई से आठ सौ रुपये मिले"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          // Mic button
          _MicButton(
            onTap: _startRecording,
            isRecording: false,
            pulseController: _pulseController,
          ),
          const SizedBox(height: 20),
          Text(
            'माइक दबाओ और बोलो',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextTertiary,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  RECORDING STATE — Pulsing mic + waveform
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildRecordingState(ThemeData theme) {
    return Padding(
      key: const ValueKey('recording'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Recording indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, _) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withValues(alpha: value),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'सुन रहे हैं ...',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'अपनी कमाई बोलो',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const Spacer(flex: 1),
          // Waveform animation
          _AudioWaveform(controller: _waveController),
          const Spacer(flex: 1),
          // Pulsing mic button (now in "stop" mode)
          _MicButton(
            onTap: _stopRecording,
            isRecording: true,
            pulseController: _pulseController,
          ),
          const SizedBox(height: 20),
          Text(
            'रोकने के लिए फिर से दबाओ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextTertiary,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PROCESSING STATE — Bhashini logo + spinner
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildProcessingState(ThemeData theme) {
    return Center(
      key: const ValueKey('processing'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bhashini icon placeholder
          AnimatedBuilder(
            animation: _processingController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _processingController.value * 2 * pi,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'समझ रहे हैं...',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by Bhashini',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.darkTextTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  RESULT STATE — Editable card
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildResultState(ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ये समझे हम',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'गलत हो तो सही करो',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Result card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount (large, editable)
                Text(
                  'राशि (Amount)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Employer name
                _ResultField(
                  label: 'नियोक्ता / काम देने वाला',
                  controller: _employerController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),

                // Work type dropdown
                Text(
                  'काम का प्रकार',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.darkBorder,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedWorkType,
                      isExpanded: true,
                      dropdownColor: AppColors.darkCard,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.darkTextSecondary),
                      items: _workTypes
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedWorkType = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date picker
                Text(
                  'तारीख',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) {
                        return Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              surface: AppColors.darkSurface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.darkTextSecondary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Save button (orange, full width)
          GestureDetector(
            onTap: _saveEntry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'सही है — सेव करो ✓',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Retry text button
          Center(
            child: TextButton(
              onPressed: _resetToIdle,
              child: Text(
                'फिर से बोलो 🎤',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  SAVED STATE — Success animation
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSavedState(ThemeData theme) {
    return Center(
      key: const ValueKey('saved'),
      child: AnimatedBuilder(
        animation: _successController,
        builder: (context, child) {
          final scale = Curves.elasticOut
              .transform(_successController.value.clamp(0, 1));
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success checkmark circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.success,
                    AppColors.success.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'हो गया! ✓',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'आपकी एंट्री सेव हो गई',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'सत्यापन लंबित',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  MIC BUTTON — 100px, pulsing rings when recording
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _MicButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isRecording;
  final AnimationController pulseController;

  const _MicButton({
    required this.onTap,
    required this.isRecording,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing outer rings (only when recording)
            if (isRecording) ...[
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, _) {
                  return _PulseRing(
                    size: 140,
                    progress: pulseController.value,
                    color: AppColors.primary,
                    opacity: 0.08,
                  );
                },
              ),
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, _) {
                  final delayed =
                      (pulseController.value - 0.3).clamp(0.0, 1.0) / 0.7;
                  return _PulseRing(
                    size: 120,
                    progress: delayed,
                    color: AppColors.primary,
                    opacity: 0.12,
                  );
                },
              ),
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, _) {
                  final delayed2 =
                      (pulseController.value - 0.5).clamp(0.0, 1.0) / 0.5;
                  return _PulseRing(
                    size: 110,
                    progress: delayed2,
                    color: AppColors.error,
                    opacity: 0.1,
                  );
                },
              ),
            ],
            // Main button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isRecording
                      ? [AppColors.error, const Color(0xFFCC3333)]
                      : [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? AppColors.error : AppColors.primary)
                        .withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: isRecording ? 42 : 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double size;
  final double progress;
  final Color color;
  final double opacity;

  const _PulseRing({
    required this.size,
    required this.progress,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final s = size * (0.6 + 0.4 * progress);
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity * (1 - progress * 0.6)),
          width: 2.5,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  AUDIO WAVEFORM ANIMATION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AudioWaveform extends StatelessWidget {
  final AnimationController controller;
  const _AudioWaveform({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            size: const Size(double.infinity, 60),
            painter: _WaveformPainter(
              phase: controller.value * 2 * pi,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double phase;
  _WaveformPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 30;
    final barWidth = size.width / barCount * 0.55;
    final gap = size.width / barCount;
    final maxH = size.height * 0.8;
    final rng = Random(42);

    for (int i = 0; i < barCount; i++) {
      final baseH = 0.2 + rng.nextDouble() * 0.4;
      final wave = sin(phase + i * 0.4) * 0.3 + 0.3;
      final h = (baseH + wave).clamp(0.1, 1.0) * maxH;
      final x = i * gap + gap / 2 - barWidth / 2;
      final y = (size.height - h) / 2;

      final paint = Paint()
        ..color = AppColors.primary.withValues(
          alpha: 0.3 + 0.7 * (h / maxH),
        )
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => old.phase != phase;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  RESULT FIELD (reusable text input for result card)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ResultField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const _ResultField({
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.darkTextTertiary, size: 20),
            filled: true,
            fillColor: AppColors.darkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
