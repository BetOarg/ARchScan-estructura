import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Replaces scanner opening controls now that all openings are positioned in
/// the shared 2D plan. The key identifies the scanner in widget tests.
class ScannerPlanOpeningHint extends StatelessWidget {
  final Key scannerKey;

  const ScannerPlanOpeningHint({
    super.key,
    required this.scannerKey,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!.openingsAddedFromPlan;
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: text,
      child: Row(
        key: scannerKey,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
