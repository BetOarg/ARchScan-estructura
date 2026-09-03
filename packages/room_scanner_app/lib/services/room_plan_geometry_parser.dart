import 'dart:math' as math;

import 'package:room_scanner_core/room_scanner_core.dart';

/// Converts the versioned native RoomPlan payload into ARchScan's stable
/// project model. This runs in CI without requiring an iPhone or LiDAR.
class RoomPlanGeometryParser {
  const RoomPlanGeometryParser({this.joinToleranceMeters = 0.20});

  final double joinToleranceMeters;

  RoomModel parseRoom(
    Map<String, dynamic> payload, {
    required String roomId,
    required String roomName,
    RoomType roomType = RoomType.other,
  }) {
    final schemaVersion = (payload['schemaVersion'] as num?)?.toInt() ?? 1;
    if (schemaVersion < 2) {
      throw const FormatException(
        'RoomPlan payload does not contain positioned geometry.',
      );
    }

    final rawWalls = payload['walls'];
    if (rawWalls is! List || rawWalls.length < 3) {
      throw const FormatException(
        'RoomPlan needs at least three positioned walls.',
      );
    }

    final segments = rawWalls
        .map((value) => _segment(value, 'wall'))
        .toList(growable: false);
    final points = _orderedContour(segments);
    if (points.length < 3) {
      throw const FormatException(
        'RoomPlan walls do not form a usable floor contour.',
      );
    }

    final features = <WallFeature>[];
    final rawOpenings = payload['openings'];
    if (rawOpenings is List) {
      for (final raw in rawOpenings) {
        final map = _map(raw, 'opening');
        final segment = _segment(map, 'opening');
        final type = map['type'] == 'window'
            ? FeatureType.window
            : FeatureType.door;
        features.add(
          WallFeature(
            id: (map['id'] as String?) ??
                'roomplan-${features.length + 1}',
            type: type,
            start: segment.$1,
            end: segment.$2,
            openingHeightMeters:
                (map['height'] as num?)?.toDouble(),
            sillHeightMeters:
                (map['sillHeight'] as num?)?.toDouble(),
          ),
        );
      }
    }

    return RoomModel(
      id: roomId,
      name: roomName,
      type: roomType,
      points: points,
      features: features,
      isClosed: true,
    );
  }

  double areaSquareMeters(List<ARPoint> points) {
    if (points.length < 3) return 0;
    var twiceArea = 0.0;
    for (var index = 0; index < points.length; index++) {
      final current = points[index];
      final next = points[(index + 1) % points.length];
      twiceArea += current.x * next.z - next.x * current.z;
    }
    return twiceArea.abs() / 2.0;
  }

  List<ARPoint> _orderedContour(
    List<(ARPoint, ARPoint)> segments,
  ) {
    final unused = List<(ARPoint, ARPoint)>.from(segments);
    final first = unused.removeAt(0);
    final ordered = <ARPoint>[first.$1, first.$2];

    while (unused.isNotEmpty) {
      final tail = ordered.last;
      var bestIndex = -1;
      var reverse = false;
      var bestDistance = double.infinity;

      for (var index = 0; index < unused.length; index++) {
        final segment = unused[index];
        final startDistance = _distance(tail, segment.$1);
        final endDistance = _distance(tail, segment.$2);
        if (startDistance < bestDistance) {
          bestDistance = startDistance;
          bestIndex = index;
          reverse = false;
        }
        if (endDistance < bestDistance) {
          bestDistance = endDistance;
          bestIndex = index;
          reverse = true;
        }
      }

      if (bestIndex < 0 || bestDistance > joinToleranceMeters) {
        throw const FormatException(
          'RoomPlan wall endpoints cannot be joined safely.',
        );
      }

      final next = unused.removeAt(bestIndex);
      ordered.add(reverse ? next.$1 : next.$2);
    }

    if (_distance(ordered.last, ordered.first) > joinToleranceMeters) {
      throw const FormatException('RoomPlan contour is open.');
    }
    ordered.removeLast();

    return _removeNearDuplicates(ordered);
  }

  List<ARPoint> _removeNearDuplicates(List<ARPoint> points) {
    final result = <ARPoint>[];
    for (final point in points) {
      if (result.isEmpty ||
          _distance(result.last, point) > joinToleranceMeters / 4) {
        result.add(point);
      }
    }
    return result;
  }

  (ARPoint, ARPoint) _segment(dynamic raw, String label) {
    final map = _map(raw, label);
    return (
      _point(map['start'], '$label.start'),
      _point(map['end'], '$label.end'),
    );
  }

  Map<String, dynamic> _map(dynamic value, String label) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('$label must be an object.');
  }

  ARPoint _point(dynamic raw, String label) {
    final map = _map(raw, label);
    final x = map['x'];
    final z = map['z'];
    if (x is! num || z is! num) {
      throw FormatException('$label requires numeric x and z.');
    }
    final y = map['y'];
    return ARPoint(
      x: x.toDouble(),
      y: y is num ? y.toDouble() : 0.0,
      z: z.toDouble(),
    );
  }

  double _distance(ARPoint a, ARPoint b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final dz = a.z - b.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }
}
