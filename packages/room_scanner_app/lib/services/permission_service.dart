import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Solicita el permiso de cámara necesario para escanear.
  static Future<bool> requestScannerPermissions() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Verifica si el permiso de cámara ya fue concedido.
  static Future<bool> hasBasicPermissions() {
    return Permission.camera.isGranted;
  }
}
