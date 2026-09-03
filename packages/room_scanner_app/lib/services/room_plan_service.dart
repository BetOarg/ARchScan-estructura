import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:room_scanner_core/room_scanner_core.dart';

import 'room_plan_geometry_parser.dart';

/// Flutter bridge for Apple's RoomPlan API (iOS 16+ with LiDAR).
class RoomPlanService {
  static const MethodChannel _channel =
      MethodChannel('com.bet0.ARchScan/roomplan');
  static const RoomPlanGeometryParser _parser =
      RoomPlanGeometryParser();

  static Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (error) {
      debugPrint('RoomPlan unavailable: $error');
      return false;
    }
  }

  /// Starts the native RoomPlan review flow and returns its versioned payload.
  ///
  /// This method remains available for diagnostics and forwards compatibility.
  static Future<Map<String, dynamic>?> startScanning() async {
    try {
      final jsonResult =
          await _channel.invokeMethod<String>('startScanning');
      if (jsonResult == null || jsonResult.isEmpty) return null;
      final decoded = jsonDecode(jsonResult);
      if (decoded is! Map) {
        throw const FormatException('RoomPlan returned a non-object payload.');
      }
      return Map<String, dynamic>.from(decoded);
    } on PlatformException catch (error) {
      debugPrint(
        'RoomPlan scan failed: ${error.code} - ${error.message}',
      );
      rethrow;
    }
  }

  /// Runs RoomPlan and converts the captured surfaces to ARchScan's persistent
  /// [RoomModel]. No project schema change is required.
  static Future<RoomModel?> scanRoom({
    required String roomId,
    required String roomName,
    RoomType roomType = RoomType.other,
  }) async {
    final payload = await startScanning();
    if (payload == null) return null;
    return _parser.parseRoom(
      payload,
      roomId: roomId,
      roomName: roomName,
      roomType: roomType,
    );
  }

  static Future<void> stopScanning() async {
    try {
      await _channel.invokeMethod<void>('stopScanning');
    } catch (error) {
      debugPrint('Unable to stop RoomPlan: $error');
    }
  }
}
