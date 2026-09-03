import 'package:flutter_test/flutter_test.dart';
import 'package:room_scanner_core/room_scanner_core.dart';
import 'package:room_scanner_ar/scanner/factories/scanner_factory.dart';
import 'package:room_scanner_ar/scanner/models/scanner_mode.dart';
import 'package:room_scanner_ar/screens/ar_scanner_screen.dart';
import 'package:room_scanner_ar/screens/basic_scanner_screen.dart';

void main() {
  const factory = ScannerFactory();
  const projectUuid = 'project-uuid';
  const projectName = 'Proyecto de prueba';

  group('ScannerFactory', () {
    test('crea ARScannerScreen para el modo AR', () {
      final screen = factory.createScreen(
        mode: ScannerMode.ar,
        projectUuid: projectUuid,
        projectName: projectName,
      );

      expect(screen, isA<ARScannerScreen>());
    });

    test('crea BasicScannerScreen para el modo Basic', () {
      final screen = factory.createScreen(
        mode: ScannerMode.basic,
        projectUuid: projectUuid,
        projectName: projectName,
      );

      expect(screen, isA<BasicScannerScreen>());
    });

    test('entrega el ambiente abierto a Basic y AR sin duplicarlo', () {
      final openRoom = RoomModel(
        id: 'open-room',
        name: 'Dormitorio',
        type: RoomType.dormitorio,
        points: [
          ARPoint(x: 0, y: 0, z: 0),
          ARPoint(x: 3, y: 0, z: 0),
        ],
        isClosed: false,
      );

      final basic = factory.createScreen(
        mode: ScannerMode.basic,
        projectUuid: projectUuid,
        projectName: projectName,
        resumeRoom: openRoom,
      ) as BasicScannerScreen;
      final ar = factory.createScreen(
        mode: ScannerMode.ar,
        projectUuid: projectUuid,
        projectName: projectName,
        resumeRoom: openRoom,
      ) as ARScannerScreen;

      expect(basic.resumeRoom, same(openRoom));
      expect(ar.resumeRoom, same(openRoom));
    });

    test('no crea una pantalla de cámara para el modo Manual', () {
      final screen = factory.createScreen(
        mode: ScannerMode.manual,
        projectUuid: projectUuid,
        projectName: projectName,
      );

      expect(screen, isNull);
    });

    test('conserva los datos del proyecto en la pantalla creada', () {
      final screen = factory.createScreen(
        mode: ScannerMode.basic,
        projectUuid: projectUuid,
        projectName: projectName,
      );

      expect(screen, isA<BasicScannerScreen>());
      final basicScreen = screen! as BasicScannerScreen;
      expect(basicScreen.projectUuid, projectUuid);
      expect(basicScreen.projectName, projectName);
    });
  });
}
