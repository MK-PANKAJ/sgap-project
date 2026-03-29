import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

enum VoiceInputStatus { idle, recording, processing, done }

class VoiceInputField extends StatefulWidget {
  final VoiceInputStatus status;
  final VoidCallback onMicPressed;
  final String? transcribedText;

  const VoiceInputField({
    super.key,
    required this.status,
    required this.onMicPressed,
    this.transcribedText,
  });

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.status == VoiceInputStatus.recording) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VoiceInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == VoiceInputStatus.recording &&
        oldWidget.status != VoiceInputStatus.recording) {
      _pulseController.repeat();
    } else if (widget.status != VoiceInputStatus.recording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hindiFont = GoogleFonts.notoSansDevanagari();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: widget.onMicPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.status == VoiceInputStatus.recording)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 80 + (_pulseController.value * 40),
                      height: 80 + (_pulseController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary
                            .withValues(alpha: 1.0 - _pulseController.value),
                      ),
                    );
                  },
                ),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: widget.status == VoiceInputStatus.processing
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        widget.status == VoiceInputStatus.recording
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text(
              widget.transcribedText!,
              style: hindiFont.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          Text(
            _getStatusMessage(),
            style: hindiFont.copyWith(
              color: AppColors.darkTextSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  String _getStatusMessage() {
    switch (widget.status) {
      case VoiceInputStatus.idle:
        return 'बोलने के लिए माइक दबाएं'; // Press mic to speak
      case VoiceInputStatus.recording:
        return 'सुन रहा हूँ... रोकने के लिए टैप करें'; // Listening... tap to stop
      case VoiceInputStatus.processing:
        return 'प्रोसेस हो रहा है...'; // Processing...
      case VoiceInputStatus.done:
        return 'पूरा हुआ'; // Done
    }
  }
}
