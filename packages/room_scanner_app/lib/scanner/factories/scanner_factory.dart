import 'package:flutter/widgets.dart';
import 'package:room_scanner_core/room_scanner_core.dart';

import '../../screens/ar_scanner_screen.dart';
import '../../screens/basic_scanner_screen.dart';
import '../models/scanner_mode.dart';

/// Crea la pantalla correspondiente al modo elegido por [ScannerModeResolver].
///
/// El modo manual no crea una pantalla de cámara. El coordinador de navegación
/// conserva el fallback seguro actual hasta que exista un flujo manual dedicado.
class ScannerFactory {
  const ScannerFactory();

  Widget? createScreen({
    required ScannerMode mode,
    required String projectUuid,
    required String projectName,
    ScanContinuationReference? continuationReference,
    RoomModel? resumeRoom,
  }) {
    return switch (mode) {
      ScannerMode.ar => ARScannerScreen(
          projectUuid: projectUuid,
          projectName: projectName,
          continuationReference: continuationReference,
          resumeRoom: resumeRoom,
        ),
      ScannerMode.basic => BasicScannerScreen(
          projectUuid: projectUuid,
          projectName: projectName,
          continuationReference: continuationReference,
          resumeRoom: resumeRoom,
        ),
      ScannerMode.manual => null,
    };
  }
}
