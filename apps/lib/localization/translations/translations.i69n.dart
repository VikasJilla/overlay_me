// ignore_for_file: unused_element, unused_field, camel_case_types, annotate_overrides, prefer_single_quotes
// GENERATED FILE, do not edit!
import 'package:i69n/i69n.dart' as i69n;

String get _languageCode => 'en';
String get _localeName => 'en';

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

class Translations implements i69n.I69nMessageBundle {
  const Translations();
  SplashTranslations get splash => SplashTranslations(this);
  WelcomeTranslations get welcome => WelcomeTranslations(this);
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
        return key;
    }
  }
}

class SplashTranslations implements i69n.I69nMessageBundle {
  final Translations _parent;
  const SplashTranslations(this._parent);
  String get overlay_me => "Overlay Me";
  String get create_amazing_photo_overlays => "Create amazing photo overlays";
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
        return key;
    }
  }
}

class WelcomeTranslations implements i69n.I69nMessageBundle {
  final Translations _parent;
  const WelcomeTranslations(this._parent);
  String welcome_back(String name) => "Welcome back, $name";
  String get ready_to_create_overlays => "Ready to create overlays?";
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
        return key;
    }
  }
}
