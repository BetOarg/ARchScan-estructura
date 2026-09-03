import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

enum RoomCompletionAction {
  addAnotherSpace,
  viewFullPlan,
}

Future<RoomCompletionAction?> showRoomCompletionDialog(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context)!;

  final route = DialogRoute<RoomCompletionAction>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return AlertDialog(
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width < 400 ? 12 : 40,
          vertical: 12,
        ),
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actionsOverflowButtonSpacing: 8,
        title: Text(l10n.spaceSaved),
      content: Text(l10n.whatWouldYouLikeToDo),
      actions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(
            dialogContext,
            RoomCompletionAction.addAnotherSpace,
          ),
          icon: const Icon(Icons.add_home_work_outlined),
          label: Text(l10n.addAnotherSpace),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(
            dialogContext,
            RoomCompletionAction.viewFullPlan,
          ),
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.viewFullPlan),
        ),
        ],
      );
    },
  );
  final result = await Navigator.of(context, rootNavigator: true).push(route);
  await route.completed;
  return result;
}
Future<bool> confirmOrthogonalContinuationClosure(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return AlertDialog(
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width < 400 ? 12 : 40,
          vertical: 12,
        ),
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actionsOverflowButtonSpacing: 8,
        title: Text(l10n.diagonalClosureDetectedTitle),
      content: Text(l10n.diagonalClosureDetectedMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.continueMeasuring),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(l10n.addCornerAndClose),
        ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
