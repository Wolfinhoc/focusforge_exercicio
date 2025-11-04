import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PrefsService {
  static late SharedPreferences _prefs;
  static const String keyPrivacyRead = 'privacy_read_v1';
  static const String keyTermsRead = 'terms_read_v1';
  static const String keyPoliciesAccepted = 'policies_version_accepted';
  static const String keyAcceptedAt = 'accepted_at';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyNotificationsOptIn = 'notifications_opt_in';
  static const String keyAvatarPath = 'avatar_path';
  static const String keyUserName = 'user_name';
  static const String keyLastSync = 'last_sync_at';
  
  static Future<void> init([SharedPreferences? prefs]) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
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

  static String? get userName => _prefs.getString(keyUserName);
  static set userName(String? v) => _prefs.setString(keyUserName, v ?? 'Usuário');

  static DateTime? get lastSync {
    final isoString = _prefs.getString(keyLastSync);
    return isoString == null ? null : DateTime.parse(isoString);
  }
  static set lastSync(DateTime? v) {
    if (v == null) {
      _prefs.remove(keyLastSync);
    } else {
      _prefs.setString(keyLastSync, v.toIso8601String());
    }
  }

  static Future<void> clearAll() async {
    // Remove o arquivo de avatar antes de limpar as prefs
    final path = _prefs.getString(keyAvatarPath);
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignora erros na deleção do arquivo
      }
    }
    await _prefs.clear();
  }

  static Future<void> removeAvatar() async {
    final path = _prefs.getString(keyAvatarPath);
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignora erros na deleção do arquivo
      }
      await _prefs.remove(keyAvatarPath);
    }
  }

  static Future<void> saveAvatar(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'avatar.jpg');
    final file = File(path);
    await file.writeAsBytes(bytes);
    await _prefs.setString(keyAvatarPath, path);
  }

  static Future<Uint8List?> loadAvatar() async {
    final path = _prefs.getString(keyAvatarPath);
    if (path == null) return null;

    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  // Métodos genéricos que estavam faltando, mas são usados pelo repositório
  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);
}
