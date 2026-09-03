import 'dart:io';

void main(List<String> arguments) {
  final strict = arguments.contains('--strict');
  final root = _findRepositoryRoot();
  final errors = <String>[];
  final warnings = <String>[];

  void requireFile(String path) {
    if (!File('${root.path}/$path').existsSync()) {
      errors.add('Falta $path.');
    }
  }

  void requireMaxCharacters(String path, int maximum) {
    final file = File('${root.path}/$path');
    if (!file.existsSync()) {
      errors.add('Falta $path.');
      return;
    }
    final value = file.readAsStringSync().trim();
    if (value.runes.length > maximum) {
      errors.add('$path supera el límite de $maximum caracteres.');
    }
  }

  void requireText(String path, String expected) {
    final file = File('${root.path}/$path');
    if (!file.existsSync()) {
      errors.add('Falta $path.');
      return;
    }
    if (!file.readAsStringSync().contains(expected)) {
      errors.add('$path no contiene el valor esperado: $expected.');
    }
  }

  const requiredFiles = [
    'packages/room_scanner_app/android/app/src/main/AndroidManifest.xml',
    'packages/room_scanner_app/ios/Runner/PrivacyInfo.xcprivacy',
    'packages/room_scanner_app/ios/Runner/en.lproj/InfoPlist.strings',
    'packages/room_scanner_app/ios/Runner/es.lproj/InfoPlist.strings',
    'docs/PUBLIC_PRIVACY_POLICY.md',
    'docs/ACCOUNT_DELETION_PAGE.md',
    'docs/STORE_LISTING_ES_EN.md',
    'docs/RELEASE_READINESS_CHECKLIST.md',
    'store_metadata/v2.7.0/submission_fields.md',
    'store_metadata/v2.7.0/en-US/subtitle.txt',
    'store_metadata/v2.7.0/en-US/keywords.txt',
    'store_metadata/v2.7.0/en-US/promotional_text.txt',
    'store_metadata/v2.7.0/en-US/review_notes.txt',
    'store_metadata/v2.7.0/en-US/whats_to_test.txt',
    'store_metadata/v2.7.0/es-AR/subtitle.txt',
    'store_metadata/v2.7.0/es-AR/keywords.txt',
    'store_metadata/v2.7.0/es-AR/promotional_text.txt',
    'store_metadata/v2.7.0/es-AR/review_notes.txt',
    'store_metadata/v2.7.0/es-AR/whats_to_test.txt',
  ];
  for (final path in requiredFiles) {
    requireFile(path);
  }

  requireText(
    'packages/room_scanner_app/android/app/build.gradle',
    'applicationId "com.bet0.ARchScan"',
  );
  requireText(
    'packages/room_scanner_app/android/app/build.gradle',
    'targetSdkVersion 36',
  );
  requireText(
    'packages/room_scanner_app/ios/Runner.xcodeproj/project.pbxproj',
    'PRODUCT_BUNDLE_IDENTIFIER = com.bet0.ARchScan;',
  );
  requireText(
    'packages/room_scanner_app/ios/Runner/Info.plist',
    '<string>ARchScan</string>',
  );
  requireText(
    'packages/room_scanner_app/ios/Runner/PrivacyInfo.xcprivacy',
    '<key>NSPrivacyTracking</key>',
  );

  for (final locale in ['en-US', 'es-AR']) {
    final prefix = 'store_metadata/v2.7.0/$locale';
    requireMaxCharacters('$prefix/subtitle.txt', 30);
    requireMaxCharacters('$prefix/keywords.txt', 100);
    requireMaxCharacters('$prefix/promotional_text.txt', 170);
    requireMaxCharacters('$prefix/review_notes.txt', 4000);
    requireMaxCharacters('$prefix/whats_to_test.txt', 4000);
  }

  final pubspec = File(
    '${root.path}/packages/room_scanner_app/pubspec.yaml',
  );
  if (pubspec.existsSync()) {
    final versionPattern = RegExp(
      r'^version: [0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$',
      multiLine: true,
    );
    if (!versionPattern.hasMatch(pubspec.readAsStringSync())) {
      errors.add('pubspec.yaml no declara una versión publicable.');
    }
  } else {
    errors.add('Falta packages/room_scanner_app/pubspec.yaml.');
  }

  final publicDocuments = [
    'docs/PUBLIC_PRIVACY_POLICY.md',
    'docs/ACCOUNT_DELETION_PAGE.md',
    'docs/STORE_LISTING_ES_EN.md',
    'store_metadata/v2.7.0/submission_fields.md',
    'store_metadata/v2.7.0/en-US/review_notes.txt',
    'store_metadata/v2.7.0/es-AR/review_notes.txt',
  ];
  for (final path in publicDocuments) {
    final file = File('${root.path}/$path');
    if (file.existsSync() &&
        RegExp(r'\[COMPLETAR[^\]]*\]').hasMatch(file.readAsStringSync())) {
      final message = '$path todavía contiene campos pendientes de completar.';
      if (strict) {
        errors.add(message);
      } else {
        warnings.add(message);
      }
    }
  }

  for (final warning in warnings) {
    stdout.writeln('ADVERTENCIA: $warning');
  }
  for (final error in errors) {
    stderr.writeln('ERROR: $error');
  }

  if (errors.isNotEmpty) {
    exitCode = 1;
    return;
  }

  stdout.writeln(
    strict
        ? 'Comprobaciones documentales estrictas verificadas; falta validar firma, AAB, SDKs, URLs públicas y Play Console.'
        : 'Estructura de publicación verificada.',
  );
}

Directory _findRepositoryRoot() {
  var directory = Directory.current.absolute;

  while (true) {
    final hasPackages =
        Directory('${directory.path}/packages').existsSync();
    final hasWorkflows =
        Directory('${directory.path}/.github/workflows').existsSync();

    if (hasPackages && hasWorkflows) {
      return directory;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('No se encontró la raíz del repositorio.');
    }
    directory = parent;
  }
}
