import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import '../engine/scanner_capabilities.dart';

/// Detecta las capacidades reales del dispositivo.
///
/// La detección de ARCore/ARKit se realiza mediante código nativo porque
/// ar_flutter_plugin_2 0.0.3 no expone un getter Dart para comprobar
/// disponibilidad de ARCore.
///
/// La ausencia de AR nunca debe impedir el funcionamiento del scanner
/// Basic o Manual.
class DeviceCapabilitiesService {
  DeviceCapabilitiesService._();

  static const MethodChannel _channel = MethodChannel(
    'com.bet0.ARchScan/device_capabilities',
  );
  static const Duration _cameraDetectionTimeout =
      Duration(seconds: 8);
  static const Duration _arDetectionTimeout =
      Duration(seconds: 5);

  /// Detecta las capacidades del dispositivo.
  static Future<ScannerCapabilities> detect() async {
    final results = await Future.wait<bool>([
      _hasCamera(),
      _hasArCore(),
      _hasArKit(),
    ]);

    return ScannerCapabilities(
      hasCamera: results[0],
      hasArCore: results[1],
      hasArKit: results[2],

      // Se detectarán posteriormente mediante ScannerSensorService.
      hasGyroscope: false,
      hasAccelerometer: false,
      hasMagnetometer: false,
    );
  }

  /// Comprueba si existe al menos una cámara disponible.
  static Future<bool> _hasCamera() async {
    try {
      final cameras = await availableCameras().timeout(
        _cameraDetectionTimeout,
      );

      return cameras.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Comprueba ARCore mediante Android nativo.
  static Future<bool> _hasArCore() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final result = await _channel
          .invokeMethod<bool>(
            'isARCoreSupported',
          )
          .timeout(_arDetectionTimeout);

      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Comprueba ARKit mediante iOS nativo.
  static Future<bool> _hasArKit() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final result = await _channel
          .invokeMethod<bool>(
            'isARKitSupported',
          )
          .timeout(_arDetectionTimeout);

      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}