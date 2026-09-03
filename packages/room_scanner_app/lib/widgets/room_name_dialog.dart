import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/recent_room_names_service.dart';

Future<String?> showRoomNameDialog({
  required BuildContext context,
  required String initialName,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final service = RecentRoomNamesService();
  final recent = await service.load();
  if (!context.mounted) return null;

  final suggestions = <String>[
    l10n.roomTypeBedroom,
    l10n.roomTypeKitchen,
    l10n.roomTypeBathroom,
    l10n.roomTypeLiving,
    l10n.roomSuggestionOffice,
    l10n.roomSuggestionStorage,
    ...recent,
  ].fold<List<String>>(<String>[], (result, item) {
    if (!result.any((value) => value.toLowerCase() == item.toLowerCase())) {
      result.add(item);
    }
    return result;
  });

  final controller = TextEditingController(text: initialName);
  final route = DialogRoute<String>(
    context: context,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width < 400 ? 12 : 40,
            vertical: 12,
          ),
          actionsOverflowAlignment: OverflowBarAlignment.end,
          actionsOverflowButtonSpacing: 8,
          title: Text(l10n.whatIsSpaceName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: l10n.roomName,
                  hintText: l10n.roomNameExample,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setDialogState(() {}),
                onSubmitted: (value) {
                  final normalized = value.trim();
                  if (normalized.isNotEmpty) {
                    Navigator.pop(dialogContext, normalized);
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: suggestions
                    .map(
                      (suggestion) => ActionChip(
                        label: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width - 96,
                          ),
                          child: Text(
                            suggestion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onPressed: () {
                          controller.text = suggestion;
                          controller.selection = TextSelection.collapsed(
                            offset: suggestion.length,
                          );
                          setDialogState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: controller.text.trim().isEmpty
                ? null
                : () => Navigator.pop(
                      dialogContext,
                      controller.text.trim(),
                    ),
            child: Text(l10n.save),
          ),
          ],
        ),
      );
    },
  );
  final name = await Navigator.of(context, rootNavigator: true).push(route);
  await route.completed;
  controller.dispose();

  if (name != null && name.trim().isNotEmpty) {
    await service.remember(name);
  }
  return name;
}
