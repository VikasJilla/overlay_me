import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:overlay_me/localization/translations/translations.i69n.dart';
import 'package:overlay_me/localization/translations/translations_es.i69n.dart';

const _translations = {'en': Translations(), 'es': Translations_es()};

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => _translations.keys.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(_translations[locale.languageCode]!);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class AppLocalizations {
  const AppLocalizations(this._translation);

  final Translations _translation;

  static final LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final List<Locale> supportedLocales = _translations.keys.map((x) => Locale(x)).toList();

  static Translations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!._translation;
}
