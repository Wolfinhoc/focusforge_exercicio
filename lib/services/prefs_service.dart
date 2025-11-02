import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static late SharedPreferences _prefs;
  static const String keyPrivacyRead = 'privacy_read_v1';
  static const String keyTermsRead = 'terms_read_v1';
  static const String keyPoliciesAccepted = 'policies_version_accepted';
  static const String keyAcceptedAt = 'accepted_at';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyNotificationsOptIn = 'notifications_opt_in';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get privacyRead => _prefs.getBool(keyPrivacyRead) ?? false;
  static set privacyRead(bool v) => _prefs.setBool(keyPrivacyRead, v);

  static bool get termsRead => _prefs.getBool(keyTermsRead) ?? false;
  static set termsRead(bool v) => _prefs.setBool(keyTermsRead, v);

  static String? get policiesVersion => _prefs.getString(keyPoliciesAccepted);
  static set policiesVersion(String? v) {
    if (v == null) _prefs.remove(keyPoliciesAccepted);
    else _prefs.setString(keyPoliciesAccepted, v);
  }

  static String? get acceptedAt => _prefs.getString(keyAcceptedAt);
  static set acceptedAt(String? v) {
    if (v == null) _prefs.remove(keyAcceptedAt);
    else _prefs.setString(keyAcceptedAt, v);
  }

  static bool get onboardingCompleted => _prefs.getBool(keyOnboardingCompleted) ?? false;
  static set onboardingCompleted(bool v) => _prefs.setBool(keyOnboardingCompleted, v);

  static bool get notificationsOptIn => _prefs.getBool(keyNotificationsOptIn) ?? false;
  static set notificationsOptIn(bool v) => _prefs.setBool(keyNotificationsOptIn, v);

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
