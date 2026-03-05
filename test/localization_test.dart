import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:df_localization/df_localization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests', () {
    setUpAll(() async {
      TranslationController.createInstance(
        translationsDirPath: 'assets/translations',
      );
      
      // Override the file reader for unit tests so we don't rely on the real AssetBundle
      TranslationController.i.setReader(
        TranslationFileReader(
          translationsDirPath: ['assets', 'translations'],
          fileType: ConfigFileType.YAML,
          fileReader: (filePath) async {
            if (filePath.contains('en-us')) {
              return 'home: Home\nlanguage: Language\nchange_language: Change Language\n';
            } else if (filePath.contains('fr-fr')) {
              return 'home: Accueil\nlanguage: Langue\nchange_language: Changer de langue\n';
            } else if (filePath.contains('ha-ng')) {
              return 'home: Gida\nlanguage: Harshe\nchange_language: Canza Harshe\n';
            }
            return '';
          },
        ),
      );
    });

    testWidgets('English translation yields correct values', (tester) async {
      await TranslationController.i.setLocale(const Locale('en', 'us'));
      await tester.pumpAndSettle();

      expect('home'.tr(), equals('Home'));
      expect('language'.tr(), equals('Language'));
      expect('change_language'.tr(), equals('Change Language'));
    });

    testWidgets('French translation yields correct values', (tester) async {
      await TranslationController.i.setLocale(const Locale('fr', 'fr'));
      await tester.pumpAndSettle();

      expect('home'.tr(), equals('Accueil'));
      expect('language'.tr(), equals('Langue'));
      expect('change_language'.tr(), equals('Changer de langue'));
    });

    testWidgets('Hausa translation yields correct values', (tester) async {
      await TranslationController.i.setLocale(const Locale('ha', 'ng'));
      await tester.pumpAndSettle();

      expect('home'.tr(), equals('Gida'));
      expect('language'.tr(), equals('Harshe'));
      expect('change_language'.tr(), equals('Canza Harshe'));
    });
  });
}
