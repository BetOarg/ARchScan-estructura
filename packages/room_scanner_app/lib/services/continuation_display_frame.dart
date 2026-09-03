import 'dart:math' as math;
import 'package:room_scanner_core/room_scanner_core.dart';

/// Keeps screen directions aligned with the project without changing stored
/// scanner-local coordinates or historical continuation references.
class ContinuationDisplayFrame {
  final ScanContinuationReference? reference;
  const ContinuationDisplayFrame(this.reference);

  double get rotation {
    final ref = reference;
    if (ref == null) return 0;
    final dx = ref.globalEnd.x - ref.globalStart.x;
    final dz = ref.globalEnd.z - ref.globalStart.z;
    if (dx * dx + dz * dz < 0.000000000001) return 0;
    final tangent = math.atan2(dz, dx);
    return ref.side == OpeningConnectionSide.left ? tangent : tangent + math.pi;
  }

  ARPoint toDisplay(ARPoint point) {
    final c = math.cos(rotation);
    final s = math.sin(rotation);
    return ARPoint(x: point.x * c - point.z * s, y: point.y,
        z: point.x * s + point.z * c);
  }

  double toLocalAngle(double screenAngle) => screenAngle - rotation * 180 / math.pi;
}
