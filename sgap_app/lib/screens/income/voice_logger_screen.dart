import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/providers/language_provider.dart'; 
import '../../core/localization/app_translations.dart'; 
import '../../widgets/sgap_app_bar.dart';

class VoiceLoggerScreen extends ConsumerStatefulWidget {
  const VoiceLoggerScreen({super.key});
  @override
  ConsumerState<VoiceLoggerScreen> createState() => _VoiceLoggerScreenState();
}

class _VoiceLoggerScreenState extends ConsumerState<VoiceLoggerScreen> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isProcessing = false;
  late AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() { _rippleCtrl.dispose(); super.dispose(); }

  Future<void> _toggleListening() async {
    if (_isProcessing) return;
    HapticFeedback.mediumImpact();
    setState(() => _isListening = !_isListening);
    
    if (!_isListening) {
      setState(() => _isProcessing = true);
      await Future.delayed(const Duration(seconds: 2));
      
      final lang = ref.read(languageProvider);
      final langCode = lang == 'English' ? 'en' : 'hi';
      
      // ERROR FIXED HERE: Changed to processVoiceLog
      await MockApiService.instance.processVoiceLog("demo audio path", langCode);
      
      if (!mounted) return;
      setState(() => _isProcessing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(lang, 'entry_saved'), style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ));
      Future.delayed(const Duration(seconds: 1), () { if (mounted) Navigator.pop(context); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hindi = GoogleFonts.notoSansDevanagari();
    final lang = ref.watch(languageProvider); 

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: SgapAppBar(title: tr(lang, 'voice_title'), showBack: true),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildMicButton(),
          const SizedBox(height: 40),
          Text(
            _isProcessing ? tr(lang, 'saving') : (_isListening ? tr(lang, 'listening') : tr(lang, 'tap_mic')),
            style: hindi.copyWith(color: _isListening ? AppColors.error : Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(20), margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder)),
            child: Text(tr(lang, 'voice_hint_text'), style: hindi.copyWith(color: AppColors.darkTextSecondary, fontSize: 14, height: 1.6), textAlign: TextAlign.center),
          ),
        ]),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: Stack(alignment: Alignment.center, children: [
        if (_isListening)
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (context, child) => Container(
              width: 120 + (_rippleCtrl.value * 60), height: 120 + (_rippleCtrl.value * 60),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.error.withValues(alpha: 1 - _rippleCtrl.value)),
            ),
          ),
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: _isListening ? [AppColors.error, const Color(0xFFE53935)] : [AppColors.primary, AppColors.primaryDark]),
            boxShadow: [BoxShadow(color: (_isListening ? AppColors.error : AppColors.primary).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: _isProcessing
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : const Icon(Icons.mic_rounded, color: Colors.white, size: 50),
        ),
      ]),
    );
  }
}