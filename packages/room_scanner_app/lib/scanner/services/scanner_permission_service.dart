import 'package:permission_handler/permission_handler.dart';

import '../models/scanner_mode.dart';

class ScannerPermissionService {
  const ScannerPermissionService();

  /// Solicita únicamente los permisos necesarios para el modo elegido.
  Future<bool> requestForMode(ScannerMode mode) async {
    switch (mode) {
      case ScannerMode.ar:
      case ScannerMode.basic:
        return _requestCameraPermission();

      case ScannerMode.manual:
        return true;
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> hasPermissionsForMode(ScannerMode mode) {
    switch (mode) {
      case ScannerMode.ar:
      case ScannerMode.basic:
        return Permission.camera.isGranted;

      case ScannerMode.manual:
        return Future<bool>.value(true);
    }
  }
}
