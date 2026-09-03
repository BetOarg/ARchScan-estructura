import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_scanner_ar/l10n/generated/app_localizations.dart';
import 'package:room_scanner_ar/widgets/scanner_plan_opening_hint.dart';

void main() {
  for (final locale in const [Locale('es'), Locale('en')]) {
    testWidgets('scanner explains plan-only openings in ${locale.languageCode}',
        (tester) async {
      tester.view.physicalSize = const Size(320, 220);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          backgroundColor: Colors.black,
          body: ScannerPlanOpeningHint(
            scannerKey: ValueKey('scanner-plan-opening-hint'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.text(l10n.openingsAddedFromPlan), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.text(l10n.door), findsNothing);
      expect(find.text(l10n.window), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
