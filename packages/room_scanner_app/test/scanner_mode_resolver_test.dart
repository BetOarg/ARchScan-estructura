import 'package:flutter_test/flutter_test.dart';
import 'package:room_scanner_ar/scanner/engine/scanner_capabilities.dart';
import 'package:room_scanner_ar/scanner/engine/scanner_mode_resolver.dart';
import 'package:room_scanner_ar/scanner/models/scanner_mode.dart';

void main() {
  const resolver = ScannerModeResolver();

  group('ScannerModeResolver', () {
    test('selecciona AR cuando ARCore está disponible', () {
      const capabilities = ScannerCapabilities(
        hasCamera: true,
        hasArCore: true,
      );

      expect(resolver.resolve(capabilities), ScannerMode.ar);
    });

    test('selecciona AR cuando ARKit está disponible', () {
      const capabilities = ScannerCapabilities(
        hasCamera: true,
        hasArKit: true,
      );

      expect(resolver.resolve(capabilities), ScannerMode.ar);
    });

    test('selecciona Basic cuando solo hay cámara', () {
      const capabilities = ScannerCapabilities(hasCamera: true);

      expect(resolver.resolve(capabilities), ScannerMode.basic);
    });

    test('selecciona Manual cuando no hay cámara ni AR', () {
      const capabilities = ScannerCapabilities();

      expect(resolver.resolve(capabilities), ScannerMode.manual);
    });
  });
}
