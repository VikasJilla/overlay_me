// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
import 'package:i69n/i69n.dart' as i69n;
import 'translations.i69n.dart';

String get _languageCode => 'es';
String get _localeName => 'es';

String _plural(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.plural(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _ordinal(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.ordinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);
String _cardinal(int count,
        {String? zero,
        String? one,
        String? two,
        String? few,
        String? many,
        String? other}) =>
    i69n.cardinal(count, _languageCode,
        zero: zero, one: one, two: two, few: few, many: many, other: other);

class Translations_es extends Translations {
  const Translations_es();
  SplashTranslations_es get splash => SplashTranslations_es(this);
  WelcomeTranslations_es get welcome => WelcomeTranslations_es(this);
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'splash':
        return splash;
      case 'welcome':
        return welcome;
      default:
        return super[key];
    }
  }
}

class SplashTranslations_es extends SplashTranslations {
  final Translations_es _parent;
  const SplashTranslations_es(this._parent) : super(_parent);
  String get overlay_me => "Superponerme";
  String get create_amazing_photo_overlays =>
      "Crea increíbles superposiciones de fotos";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'overlay_me':
        return overlay_me;
      case 'create_amazing_photo_overlays':
        return create_amazing_photo_overlays;
      default:
        return super[key];
    }
  }
}

class WelcomeTranslations_es extends WelcomeTranslations {
  final Translations_es _parent;
  const WelcomeTranslations_es(this._parent) : super(_parent);
  String welcome_back(String name) => "Bienvenido de nuevo, $name";
  String get ready_to_create_overlays => "Listo para crear superposiciones?";
  Object operator [](String key) {
    var index = key.indexOf('.');
    if (index > 0) {
      return (this[key.substring(0, index)]
          as i69n.I69nMessageBundle)[key.substring(index + 1)];
    }
    switch (key) {
      case 'welcome_back':
        return welcome_back;
      case 'ready_to_create_overlays':
        return ready_to_create_overlays;
      default:
        return super[key];
    }
  }
}
