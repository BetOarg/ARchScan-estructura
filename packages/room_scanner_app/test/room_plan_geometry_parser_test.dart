import 'package:flutter_test/flutter_test.dart';
import 'package:room_scanner_ar/services/room_plan_geometry_parser.dart';
import 'package:room_scanner_core/room_scanner_core.dart';

Map<String, dynamic> point(double x, double z) =>
    <String, dynamic>{'x': x, 'y': 0.0, 'z': z};

Map<String, dynamic> wall(
  String id,
  double ax,
  double az,
  double bx,
  double bz,
) =>
    <String, dynamic>{
      'id': id,
      'start': point(ax, az),
      'end': point(bx, bz),
    };

void main() {
  const parser = RoomPlanGeometryParser();

  test('rebuilds a closed RoomModel from unordered RoomPlan walls', () {
    final payload = <String, dynamic>{
      'schemaVersion': 2,
      'walls': <Map<String, dynamic>>[
        wall('right', 4, 3, 4, 0),
        wall('top', 0, 3, 4, 3),
        wall('left', 0, 0, 0, 3),
        wall('bottom', 4, 0, 0, 0),
      ],
      'openings': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'door-1',
          'type': 'door',
          'start': point(1, 0),
          'end': point(2, 0),
          'height': 2.1,
          'sillHeight': 0.0,
        },
        <String, dynamic>{
          'id': 'window-1',
          'type': 'window',
          'start': point(4, 1),
          'end': point(4, 2),
          'height': 1.2,
          'sillHeight': 0.9,
        },
      ],
    };

    final room = parser.parseRoom(
      payload,
      roomId: 'room-1',
      roomName: 'RoomPlan room',
    );

    expect(room.isClosed, isTrue);
    expect(room.points, hasLength(4));
    expect(room.features, hasLength(2));
    expect(room.features.first.type, FeatureType.door);
    expect(room.features.last.type, FeatureType.window);
    expect(parser.areaSquareMeters(room.points), closeTo(12.0, 0.001));
  });

  test('rejects the legacy dimensions-only payload', () {
    expect(
      () => parser.parseRoom(
        <String, dynamic>{
          'walls': <Map<String, dynamic>>[
            <String, dynamic>{'length': 4, 'height': 2.5},
          ],
        },
        roomId: 'room-1',
        roomName: 'Invalid',
      ),
      throwsFormatException,
    );
  });

  test('rejects a contour whose endpoints cannot be joined safely', () {
    expect(
      () => parser.parseRoom(
        <String, dynamic>{
          'schemaVersion': 2,
          'walls': <Map<String, dynamic>>[
            wall('a', 0, 0, 4, 0),
            wall('b', 10, 0, 10, 3),
            wall('c', 10, 3, 0, 3),
          ],
        },
        roomId: 'room-1',
        roomName: 'Open',
      ),
      throwsFormatException,
    );
  });
}
