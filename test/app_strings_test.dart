import 'package:flutter_test/flutter_test.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/models/enums.dart';

void main() {
  group('AppStrings', () {
    test('resolves a key in the selected language', () {
      const AppStrings english = AppStrings(AppLanguage.english);
      const AppStrings tamil = AppStrings(AppLanguage.tamil);
      const AppStrings hindi = AppStrings(AppLanguage.hindi);

      expect(english('nav.home'), 'Home');
      expect(tamil('nav.home'), isNot('Home'));
      expect(hindi('nav.home'), isNot('Home'));
    });

    test('never throws on a missing key — falls back to English, then the key',
        () {
      const AppStrings tamil = AppStrings(AppLanguage.tamil);
      // A key that exists nowhere must come back as itself, not an exception.
      expect(tamil('this.key.does.not.exist'), 'this.key.does.not.exist');
    });

    test('substitutes {placeholders}', () {
      const AppStrings english = AppStrings(AppLanguage.english);
      expect(
        english.withArgs('home.greeting.morning', <String, String>{
          'name': 'Murugan',
        }),
        'Good morning, Murugan',
      );
    });

    test('every Tamil and Hindi key also exists in English', () {
      // Guards against a translation key drifting away from the source table.
      for (final String key in AppStrings.ta.keys) {
        expect(AppStrings.en.containsKey(key), isTrue,
            reason: 'Tamil key "$key" has no English source');
      }
      for (final String key in AppStrings.hi.keys) {
        expect(AppStrings.en.containsKey(key), isTrue,
            reason: 'Hindi key "$key" has no English source');
      }
    });

    test('translation coverage is complete for both languages', () {
      expect(AppStrings.coverageOf(AppLanguage.tamil), 100);
      expect(AppStrings.coverageOf(AppLanguage.hindi), 100);
    });

    test('no English value is left empty', () {
      for (final MapEntry<String, String> entry in AppStrings.en.entries) {
        expect(entry.value.trim().isNotEmpty, isTrue,
            reason: 'Empty English value for "${entry.key}"');
      }
    });
  });
}
