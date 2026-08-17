import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_getInitialLocale()) {
    _loadStoredLocale();
  }

  static const String _settingsBoxName = 'settings_box';
  static const String _localeKey = 'user_locale';

  static Locale _getInitialLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'pt') {
      return const Locale('pt', 'BR');
    } else if (deviceLocale.languageCode == 'es') {
      return const Locale('es');
    }
    return const Locale('en', 'US');
  }

  Future<void> _loadStoredLocale() async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      final storedCode = box.get(_localeKey) as String?;
      if (storedCode != null && storedCode.isNotEmpty) {
        state = _parseLocaleCode(storedCode);
      }
    } catch (_) {}
  }

  static Locale _parseLocaleCode(String code) {
    if (code.contains('pt')) {
      return const Locale('pt', 'BR');
    } else if (code.contains('es')) {
      return const Locale('es');
    } else {
      return const Locale('en', 'US');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    final code = '${newLocale.languageCode}_${newLocale.countryCode ?? ''}';

    // 1. Local Storage (Hive)
    try {
      final box = await Hive.openBox(_settingsBoxName);
      await box.put(_localeKey, code);
    } catch (_) {}

    // 2. Remote Storage (Firestore)
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'languagePreference': code}, SetOptions(merge: true));
      }
    } catch (_) {}
  }
}
