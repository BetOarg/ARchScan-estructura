import 'dart:math' as math;

import 'package:room_scanner_core/room_scanner_core.dart';

/// Rigid 2D calibration used when an open room is resumed in a new AR session.
///
/// Two known vertices determine translation and rotation. Distances and angles
/// from the historical project are preserved; Y is translated relative to the
/// selected starting vertex.
class ResumeRoomCalibration {
  const ResumeRoomCalibration._({
    required this.modelPrevious,
    required this.modelStart,
    required this.sessionPrevious,
    required this.sessionStart,
    required this.modelLength,
    required this.sessionLength,
  });

  final ARPoint modelPrevious;
  final ARPoint modelStart;
  final ARPoint sessionPrevious;
  final ARPoint sessionStart;
  final double modelLength;
  final double sessionLength;

  static ResumeRoomCalibration? tryCreate({
    required ARPoint modelPrevious,
    required ARPoint modelStart,
    required ARPoint sessionPrevious,
    required ARPoint sessionStart,
  }) {
    final modelLength = math.sqrt(
      math.pow(modelStart.x - modelPrevious.x, 2) +
          math.pow(modelStart.z - modelPrevious.z, 2),
    );
    final sessionLength = math.sqrt(
      math.pow(sessionStart.x - sessionPrevious.x, 2) +
          math.pow(sessionStart.z - sessionPrevious.z, 2),
    );
    if (modelLength < 0.000001 || sessionLength < 0.000001) return null;
    return ResumeRoomCalibration._(
      modelPrevious: modelPrevious,
      modelStart: modelStart,
      sessionPrevious: sessionPrevious,
      sessionStart: sessionStart,
      modelLength: modelLength,
      sessionLength: sessionLength,
    );
  }

  ARPoint transform(ARPoint point) {
    final sessionTx =
        (sessionStart.x - sessionPrevious.x) / sessionLength;
    final sessionTz =
        (sessionStart.z - sessionPrevious.z) / sessionLength;
    final modelTx = (modelStart.x - modelPrevious.x) / modelLength;
    final modelTz = (modelStart.z - modelPrevious.z) / modelLength;

    final relativeX = point.x - sessionStart.x;
    final relativeZ = point.z - sessionStart.z;
    final along = relativeX * sessionTx + relativeZ * sessionTz;
    final left = relativeX * -sessionTz + relativeZ * sessionTx;

    return ARPoint(
      x: modelStart.x + along * modelTx + left * -modelTz,
      y: modelStart.y + point.y - sessionStart.y,
      z: modelStart.z + along * modelTz + left * modelTx,
    );
  }
}
