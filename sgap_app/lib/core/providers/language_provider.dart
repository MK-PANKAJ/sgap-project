// lib/core/providers/language_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Default language humne 'English' set ki hai.
final languageProvider = StateProvider<String>((ref) => 'English');