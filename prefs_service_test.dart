import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusforge/services/prefs_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockPathProviderPlatform mockPathProvider;
  late String tempPath;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockPrefs = MockSharedPreferences();
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;

    final tempDir = await Directory.systemTemp.createTemp('test_');
    tempPath = tempDir.path;

    when(() => mockPathProvider.getApplicationDocumentsDirectory())
        .thenAnswer((_) async => tempPath);

    await PrefsService.init(mockPrefs);
  });

  tearDown(() async {
    final tempDir = Directory(tempPath);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PrefsService Avatar Tests', () {
    test('deve salvar o avatar e o caminho nas preferências', () async {
      final avatarPath = '$tempPath/avatar.jpg';
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      // Configura o mock para a chamada de setString
      when(() => mockPrefs.setString(PrefsService.keyAvatarPath, avatarPath))
          .thenAnswer((_) async => true);

      await PrefsService.saveAvatar(imageBytes);

      final file = File(avatarPath);
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), equals(imageBytes));
      verify(() => mockPrefs.setString(PrefsService.keyAvatarPath, avatarPath)).called(1);
    });

    test('deve carregar o avatar do disco', () async {
      final avatarPath = '$tempPath/avatar.jpg';
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      await File(avatarPath).writeAsBytes(imageBytes);

      when(() => mockPrefs.getString(PrefsService.keyAvatarPath)).thenReturn(avatarPath);

      final loadedBytes = await PrefsService.loadAvatar();

      expect(loadedBytes, isNotNull);
      expect(loadedBytes, equals(imageBytes));
    });

    test('deve remover o avatar do disco e das preferências', () async {
      final avatarPath = '$tempPath/avatar.jpg';
      await File(avatarPath).writeAsBytes(Uint8List(0));

      when(() => mockPrefs.getString(PrefsService.keyAvatarPath)).thenReturn(avatarPath);
      when(() => mockPrefs.remove(PrefsService.keyAvatarPath)).thenAnswer((_) async => true);

      await PrefsService.removeAvatar();

      expect(await File(avatarPath).exists(), isFalse);
      verify(() => mockPrefs.remove(PrefsService.keyAvatarPath)).called(1);
    });
  });
}