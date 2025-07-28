import 'package:flutter/material.dart';
import 'package:overlay_me/localization/app_localizations.dart';
import 'package:overlay_me/localization/translations/translations.i69n.dart';

extension ContextExtension on BuildContext {
  Translations get translations => AppLocalizations.of(this);
}
