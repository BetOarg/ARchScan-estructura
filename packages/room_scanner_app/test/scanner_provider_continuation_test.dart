import 'package:flutter_test/flutter_test.dart';
import 'package:room_scanner_ar/providers/scanner_provider.dart';
import 'package:room_scanner_core/room_scanner_core.dart';

void main() {
  test('el cierre de continuación conserva la primera esquina real', () {
    final provider = ScannerProvider();
    provider.startNewRoom(
      initialFeatures: [
        WallFeature(
          id: 'opening-reference',
          type: FeatureType.door,
          start: ARPoint(x: -0.9, y: 0, z: 0),
          end: ARPoint(x: 0, y: 0, z: 0),
        ),
      ],
    );

    provider.tryAddPoint(1, 0, 1);
    provider.tryAddPoint(4, 0, 1);
    provider.tryAddPoint(4, 0, 3);

    final suggestion = ScanValidator.suggestOrthogonalClosurePoint(
      provider.currentRoom!.points,
    );
    expect(suggestion, isNotNull);
    provider.tryAddPoint(
      suggestion!.x,
      suggestion.y,
      suggestion.z,
    );

    final closed = provider.closeCurrentRoom();

    expect(closed, isNotNull);
    expect(closed!.points.first.x, closeTo(1, 0.000001));
    expect(closed.points.first.z, closeTo(1, 0.000001));
    expect(
      closed.points.any(
        (point) =>
            point.x.abs() <= 0.000001 &&
            point.z.abs() <= 0.000001,
      ),
      isFalse,
    );
    expect(closed.features.single.id, 'opening-reference');
  });
}
